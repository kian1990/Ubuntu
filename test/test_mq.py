import pika

# 连接到RabbitMQ服务器
connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
channel = connection.channel()

# 声明一个队列
channel.queue_declare(queue='hello')

# 发送消息
channel.basic_publish(exchange='', routing_key='hello', body='Hello, RabbitMQ!')
print(" [x] Sent 'Hello, RabbitMQ!'")

# 关闭连接
connection.close()
