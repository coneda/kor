import re, xlrd, xlwt
wp = __import__('wp-lib')

def list2dict(triple):
	try:
		d = {'id': str(int(triple[0])), 'dating_string': triple[1], 'label': triple[2]}
	except:
		d = {'id': triple[0], 'dating_string': triple[1], 'label': triple[2]}
	return d

if __name__ == '__main__':
	# Read sheet of index
	filename = './entities.0001.new.xls'
	sheet = xlrd.open_workbook(filename)
	sheet = sheet.sheet_by_index(0)
	data = [sheet.row_values(i) for i in range(sheet.nrows)]
	data_t = [sheet.col_values(i) for i in range(sheet.ncols)]
	header = data[0]

	# Column P
	p_idx = []
	p_res = []
	for i, item in enumerate(header):
		if re.findall('(id_|dating_string_|label_)', item):
			p_idx.append(i)
	assert(len(p_idx) % 3 == 0)
	max_num_p = int(len(p_idx) / 3)
	for line in data[1:]:
		item = [['', '', ''] for i in range(max_num_p)]
		res = []
		for idx in p_idx:
			if header[idx].startswith('id_'):
				item[int(header[idx][3:])][0] = line[idx]
			if header[idx].startswith('dating_string_'):
				item[int(header[idx][14:])][1] = line[idx]
			if header[idx].startswith('label_'):
				item[int(header[idx][6:])][2] = line[idx]
		for triple in item:
			if triple != ['', '', '']:
				res.append(list2dict(triple))
		p_res.append(str(res))

	# Column Q
	q_idx = []
	q_res = []
	keys = []
	for i, item in enumerate(header):
		if i <= p_idx[-1]:
			continue
		if item != 'Blaue Markierung' and item != 'Eigentumsvermerk':
			q_idx.append(i)
			keys.append(item)
	for line in data[1:]:
		d = {}
		for idx in q_idx:
			if line[idx] != '':
				d[header[idx]] = line[idx]
		q_res.append(str(d))

	# Column R
	r_idx = []
	r_res = []
	keys = []
	for i, item in enumerate(header):
		if i <= p_idx[-1]:
			continue
		if item == 'Blaue Markierung' or item == 'Eigentumsvermerk':
			r_idx.append(i)
			keys.append(item)
	for line in data[1:]:
		res = []
		for idx in r_idx:
			if line[idx] != '':
				res.append({'label': header[idx], 'value': line[idx]})
		r_res.append(str(res))

	#
	f = open('wp5Back.csv', 'w')
	f.write(','.join(['datings', 'dataset', 'properties']) + '\n')
	for line in zip(p_res, q_res, r_res):
		f.write(','.join([wp.asCell(item) for item in line]) + '\n')
	f.close()

	#
	result = [sheet.col_values(i) for i in range(19)]
	result[15] = [result[15][0]] + p_res
	result[16] = [result[16][0]] + q_res
	result[17] = [result[17][0]] + r_res

	workbook = xlwt.Workbook()
	write_sheet = workbook.add_sheet('Sheet')
	for i, col in enumerate(result):
		for j in range(len(col)):
			write_sheet.write(j, i, col[j])
	workbook.save(filename.replace('.new.xls', '.back.xls'))

