from flask import Flask, render_template, request
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField
from wtforms.validators import DataRequired
import mysql.connector

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your_secret_key'

# MySQL数据库连接
def connect_to_database(host, user, password, database):
    return mysql.connector.connect(
        host=host,
        user=user,
        password=password,
        database=database
    )

class QueryForm(FlaskForm):
    username = StringField('用户', validators=[DataRequired()])
    password = PasswordField('密码', validators=[DataRequired()])
    database = StringField('数据库', validators=[DataRequired()])
    table = StringField('表', validators=[DataRequired()])
    query = StringField('条件', validators=[DataRequired()])
    submit = SubmitField('查询')

@app.route('/', methods=['GET', 'POST'])
def index():
    form = QueryForm()
    results = None

    if form.validate_on_submit():
        username = form.username.data
        password = form.password.data
        database = form.database.data
        table = form.table.data
        query = form.query.data

        # 检查用户名和密码是否正确
        if username == 'root' and password == 'root':
            mydb = connect_to_database("localhost", username, password, database)
            mycursor = mydb.cursor()
            mycursor.execute(f"SELECT * FROM {table} WHERE {query}")
            results = mycursor.fetchall()
        else:
            results = [('用户名或密码错误')]

    return render_template('index.html', form=form, results=results)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
