const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const app = express();
const port = 8000;

// 使用 body-parser 中间件来解析 POST 请求的数据
app.use(bodyParser.urlencoded({ extended: true }));

// 显示输入 MySQL 连接信息的页面
app.get('/', (req, res) => {
  res.sendFile(__dirname + '/index.html');
});

// 处理用户提交的 MySQL 连接信息并执行查询
app.post('/query', (req, res) => {
  const { username, password, database, table } = req.body;

  // 创建 MySQL 连接
  const connection = mysql.createConnection({
    host: 'localhost',
    user: username,
    password: password,
    database: database
  });

  // 连接到数据库
  connection.connect((err) => {
    if (err) {
      console.error('Error connecting to database: ' + err.stack);
      res.status(500).send('Error connecting to database');
      return;
    }

    const query = `SELECT * FROM ${table}`;

    connection.query(query, (error, results) => {
      if (error) {
        res.status(500).send('Error executing query');
      } else {
        res.json(results);
      }

      // 关闭数据库连接
      connection.end();
    });
  });
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}/`);
});
