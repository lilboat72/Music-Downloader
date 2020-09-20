# REST api
import Utilities
import socket
from flask import Flask, request

app = Flask(__name__)
app.config['DEBUG'] = False
port = ''

def choose_port():
    global port
    for _port in range(1024,49152):# actually ends at 49152
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            s.bind(('', _port)) # See if _port is available
        except OSError as e:
            print(e)
            break
        else:
            print('Port accepted!!')
            s.close()
            port = _port
            Utilities.Config().setServerLocation(port)
            runApp()
            break
            
def runApp():
    app.run(port=port)

@app.route('/',methods = ['GET'])
def home():
    return '<h1>MUSIC DOWNLOADER API</h1>'

@app.route('/downloadSingle',methods = ['GET'])
def downloadSingle():
    Utilities.DownloadThis().downloadSingle()
    return 'Download single'

@app.route('/downloadPlaylist',methods = ['GET'])
def downloadPlaylist():
    Utilities.DownloadThis().downloadPlaylist()
    return 'Download Playlist'

# As of now it sends to lolzgoat@gmail.com
@app.route('/sendFeedback',methods = ['GET'])
def _sendFeedback():
    Utilities.Feedback().sendFeedback()
    return 'Send feedback'

choose_port()
