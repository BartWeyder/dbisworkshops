import cx_Oracle
from dao.credentials import username, password, databaseName

def add_tag(title):
	connection = cx_Oracle.connect(username, password, databaseName)
	cursor = connection.cursor()
	status = cursor.var(cx_Oracle.STRING)
	cursor.callproc("TAG_HANDLE.add_tag", [status, title])
	connection.commit()
	cursor.close()
	connection.close()
	return status.getvalue()

def delete_tag(title):
	connection = cx_Oracle.connect(username, password, databaseName)
	cursor = connection.cursor()
	status = cursor.var(cx_Oracle.STRING)
	cursor.callproc("TAG_HANDLE.delete_tag", [status, title])
	connection.commit()
	cursor.close()
	connection.close()
	return status.getvalue()

def get_tag(title):
	if not title: return None
	
	connection = cx_Oracle.connect(username, password, databaseName)
	cursor = connection.cursor()
	tag = cursor.callfunc("TAG_HANDLE.get_tag", cx_Oracle.CURSOR, [title]).fetchone()
	cursor.close()
	connection.close()

	return tag

def filter_tags(title=None, deleted=None):
	query = "select * from TABLE(TAG_HANDLE.filter_tags(:title, :deleted))" 
	connection = cx_Oracle.connect(username, password, databaseName)
	cursor = connection.cursor()
	try:
		cursor.execute(query, title=title, deleted=deleted)
		data = cursor.fetchall()
	except:
		raise
	finally:
		cursor.close()
		connection.close()
	return data
