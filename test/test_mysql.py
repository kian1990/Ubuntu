import mysql.connector

# 连接到 MySQL 数据库
conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='root',
    database='test'
)

# 创建一个游标对象
cursor = conn.cursor()

# 执行查询
query = "SELECT * FROM websites"
cursor.execute(query)

# 获取查询结果
for row in cursor.fetchall():
    print(row)

# 关闭游标和连接
cursor.close()
conn.close()

