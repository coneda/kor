import os, sys, xlrd, xlwt
wp = __import__('wp-lib')

if __name__ == '__main__':
	# Read sheet of index
	filename = './entities.0001.xls'
	sheet = xlrd.open_workbook(filename)
	sheet = sheet.sheet_by_index(0)

	# Read column values
	col_p = sheet.col_values(15)[1: ]
	col_q = sheet.col_values(16)[1: ]
	col_r = sheet.col_values(17)[1: ]
	col_p = [eval(item) for item in col_p]
	col_q = [eval(item) for item in col_q]
	col_r = [eval(item) for item in col_r]
	assert(len(col_p) == len(col_q))
	assert(len(col_q) == len(col_r))
	header = ['Col P', 'Col Q', 'Col R']
	result = [[p, q, r] for p, q, r in zip(col_p, col_q, col_r)]
	print(len(header), len(result[0]), len(result[-1]))

	# Column P
	max_len = 0
	dict_key = set()
	for line in col_p:
		max_len = max(max_len, len(line))
		for d in line:
			for k in d:
				dict_key.add(k)
	assert(len(dict_key) == 3)
	keys = []
	for i in range(max_len):
		for k in dict_key:
			keys.append(k + '_%d' % i)
	header.extend(keys)
	for i, line in enumerate(col_p):
		res = dict(zip(keys, ['' for k in keys]))
		for j, d in enumerate(line):
			for k in d:
				res[k + '_%d' % j] = d[k]
		assert(len(res) == len(keys))
		for k in keys:
			result[i].append(res[k])
	print(len(header), len(result[0]), len(result[-1]))

	# Column Q
	keys = set()
	for d in col_q:
		for k in d:
			if d[k] != '':
				keys.add(k)
	keys = list(keys)
	header.extend(keys)
	for i, d in enumerate(col_q):
		res = dict(zip(keys, ['' for k in keys]))
		for k in d:
			if d[k] != '':
				res[k] = d[k]
		assert(len(res) == len(keys))
		for k in keys:
			result[i].append(res[k])
	print(len(header), len(result[0]), len(result[-1]))

	# Column R
	keys = set()
	for line in col_r:
		for d in line:
			assert(len(d) == 2)
			assert('label' in d)
			assert('value' in d)
			keys.add(d['label'])
	keys = list(keys)
	header.extend(keys)
	for i, line in enumerate(col_r):
		res = dict(zip(keys, ['' for k in keys]))
		for d in line:
			res[d['label']] = d['value']
		assert(len(res) == len(keys))
		for k in keys:
			result[i].append(res[k])
	print(len(header), len(result[0]), len(result[-1]))

	#
	f = open('wp5.csv', 'w')
	f.write(','.join(header) + '\n')
	for i, line in enumerate(result):
		print(i + 1, len(result), len(line))
		f.write(','.join([wp.asCell(str(item)) for item in line]) + '\n')
	f.close()

	header = header[3:]
	result = [item[3:] for item in result]
	new_data = [[header[i]] + [result[j][i] for j in range(len(result))] for i in range(len(header))]
	data = [sheet.col_values(i) for i in range(sheet.ncols)]
	data.extend(new_data)

	workbook = xlwt.Workbook()
	write_sheet = workbook.add_sheet('Sheet')
	for i, col in enumerate(data):
		for j in range(len(col)):
			write_sheet.write(j, i, col[j])
	workbook.save(filename.replace('.xls', '.new.xls'))

