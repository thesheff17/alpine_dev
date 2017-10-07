from flask import Flask

app = Flask(__name__)
app.config['DEBUG'] = True


@app.route('/')
def hello_world():
    message = 'Hello World. Welcome to the Flask Dev Server.' + \
              '<br/>Created By: Dan Sheffner'
    return message

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8000)
