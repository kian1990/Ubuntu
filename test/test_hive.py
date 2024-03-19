from pyhive import hive

# 连接到Hive数据库
conn = hive.Connection(host='localhost', port=10000, username='root')

# 创建一个游标对象
cursor = conn.cursor()

# 执行一个查询
cursor.execute('SELECT * FROM web')

# 获取查询结果
for result in cursor.fetchall():
    print(result)

# 关闭连接
cursor.close()
conn.close()

