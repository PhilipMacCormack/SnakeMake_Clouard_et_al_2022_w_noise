"""
this script makes the following translations to vcf.gz file

GT  -> GT:DS:GP
0/0 -> 0|0:0:1,0,0
0/1 -> 0|1:1:0,1,0
1/1 -> 1|1:2:0,0,1

"""

import pandas as pd
import gzip


# unzip file
def gunzip(fname, block_size=65536):
    # modified from https://stackoverflow.com/questions/52332897/how-to-extract-a-gz-file-in-python
    source=fname+'.gz'
    with gzip.open(source, 'rb') as s_file, \
            open(fname, 'wb') as d_file:
        while True:
            block = s_file.read(block_size)
            if not block:
                break
            else:
                d_file.write(block)

fname = "Output/for_evaluate_prophaser/IMP.chr20.pooled.imputed.vcf"
gunzip(fname)

# file2
fname2 = "Output/splitting/IMP.chr20.snps.gt.vcf"
gunzip(fname2)


# extract pre-data lines
def get_pre_data(fname):
    pre_header = []
    header = ''
    with open(fname, "r") as f:
        for line in f.readlines():
            if not header == '': # when header has been read
                return (pre_header, header)
            li = line.lstrip()
            if li.startswith('##'): # pre-header lines
                pre_header.append(li)
            elif li.startswith("#"): # header
                    header = li[:-1]

pre_data = get_pre_data(fname)
pre_header = pre_data[0]
header = pre_data[1].split(sep='\t')

# file2
pre_data2 = get_pre_data(fname2)
pre_header2 = pre_data2[0]
header2 = pre_data2[1].split(sep='\t')

# read dataframe from ignoring pre-data
data = pd.read_csv(fname, comment='#', sep='\t', names=header)

# file2
data2 = pd.read_csv(fname2, comment='#', sep='\t', names=header2)
new_ids = data2.loc[:, 'ID'].to_list()

# do translation on columns
# second element replaces the first
find_replace1 = ['GT', 'GT:DS:GP']
find_replace2 = ['0/0', '0|0:0:1,0,0']
find_replace3 = ['0/1', '0|1:1:0,1,0']
find_replace4 = ['1/1', '1|1:2:0,0,1']
data = data.replace(to_replace=[find_replace1[0], find_replace2[0], find_replace3[0], find_replace4[0]],
                    value=[find_replace1[1], find_replace2[1], find_replace3[1], find_replace4[1]])

# replace ids
data.loc[:, 'ID'] = new_ids


# assemble and write gz-compressed outfile
def good_as_new(fname, pre_header, data):
    def elemental_concat(lst):
        # returns string of concatenated list elements
        S = ''
        for s in lst:
            S = S+'\t'+str(s)
        return S[1:]+'\n'

    # prepare dataframe for writing
    rows = [data.iloc[r, :].to_list() for r in range(data.shape[0])]
    rows = [elemental_concat(row) for row in rows]

    # writing
    f = open(fname, 'w')
    [f.write(comment) for comment in pre_header]
    f.write(elemental_concat(header))
    [f.write(row) for row in rows]
    f.close()

good_as_new(fname, pre_header, data)



'''
# assemble and write gz-compressed outfile
def good_as_new(fname, pre_header, data):
    def elemental_concat(lst):
        # returns string of concatenated list elements
        S = ''
        for s in lst:
            S = S+'\t'+str(s)
        return S[1:]+'\n'

    # prepare dataframe for writing
    rows = [data.iloc[r, :].to_list() for r in range(data.shape[0])]
    rows = [elemental_concat(row) for row in rows]

    # writing
    f = gzip.open(fname, 'wb')
    [f.write(comment.encode('UTF-8')) for comment in pre_header]
    f.write(b'##reformated GT -> GT:DS:GP\n')
    f.write(elemental_concat(header).encode('UTF-8'))
    [f.write(row.encode('UTF-8')) for row in rows]
    f.close()

good_as_new(fname+'.gz', pre_header, data)

'''



