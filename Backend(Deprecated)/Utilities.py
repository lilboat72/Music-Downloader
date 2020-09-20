'''
On the backend side of things only this file will read or modify json files
'''

from __future__ import unicode_literals
import youtube_dl
import json
import Email_service

communicationFile = 'communication.json'
musicdataFile = 'music_data.json'

class MyJson:
    def read_json(self,file):
        with open(file, "r") as file:
            return json.load(file)

    def write_json(self,file,contents):
        with open(file,"w") as file:
            json.dump(contents, file, indent=4)

class Config:
    def setServerLocation(self,port):
        json_object = MyJson().read_json(communicationFile)
        json_object["serverLocation"] = f'http://localhost:{port}'
        MyJson().write_json(communicationFile,json_object)

class Feedback:
    def sendFeedback(self):
        json_object = MyJson().read_json(communicationFile)
        FeedbackType = json_object["Feedback"][0]
        body = json_object["Feedback"][1]
        Email_service.sendEmail(FeedbackType,body)

class DownloadThis:
    """Assumes urls are present"""
    music = []
    json_object = MyJson().read_json(musicdataFile) 
    success = {} # {url:name}
    failed = {} # {url:name}
    count = -1

    def error_handler(self,msg = '',solution = '',id = '',all = False):
        if all:
            print(msg)
            print(solution)
            self.failed[self.music[self.count::]] = [self.json_object[id][self.music[self.count]],msg,solution] # {url:[name,msg,solution]} add all remaining music
        else:
            print(msg)
            print(solution)
            self.failed[self.music[self.count]] = [self.json_object[id][self.music[self.count]],msg,solution] # {url:[name,msg,solution]}

    def downloadSingle(self):
        id = "Singles"
        # Add urls to music
        self.music = list(self.json_object[id].keys()) # url

        # Download options
        ydl_opts = {
            'format': 'bestaudio/best',
            'hls_prefer_native': True,
            'outtmpl':'Audios/%(title)s.%(ext)s',
            # 'quiet':True,# Don't print messages
            'postprocessors': [{
                'key': 'FFmpegExtractAudio',
                'preferredcodec': 'm4a',
                'preferredquality': '192',
            }],
        }
        with youtube_dl.YoutubeDL(ydl_opts) as ydl:
            while self.count != len(self.music) - 1:
                self.count+=1
                item = self.music[self.count]
                try:
                    ydl.download([item])
                    self.success[self.music[self.count]] = self.json_object[id][self.music[self.count]] # {url:name}
                    #self.count+=1
                    print(self.count)
                    print('------------------------------------------------------------------------')
                except youtube_dl.utils.DownloadError as e:
                    self.error_handler(msg='Failed download', solution='',id=id),
                    print(e)
                except youtube_dl.utils.GeoRestrictedError as e:
                    self.error_handler(msg='This song is not available in your region', solution='',id=id)
                    print(e)
                except youtube_dl.utils.MaxDownloadsReached as e:
                    self.error_handler(msg='Sorry but you have reached your maximum downloads', solution='', id=id, all=True)
                    print(e)
                    break
                except youtube_dl.utils.UnsupportedError as e:
                    self.error_handler(msg='Unsupported', solution='',id=id)
                    print(e)
                except youtube_dl.utils.UnavailableVideoError as e:
                    self.error_handler(msg='Not available in mp3 format', solution='', id=id)
                    print(e)
                except youtube_dl.utils.YoutubeDLError as e:
                    self.error_handler(msg='FATAL YOUTUBE_DL ERROR', solution='', id=id)
                    print(e)
                except Exception as e:
                    self.error_handler(msg='ERROR UNKNOWN', solution='', id=id)
                    print(e)
                    break
            #1.Clear Singles after downloading all music 2.Add to finished dwnloads and failed downloads
            self.json_object[id].clear()
            self.json_object["finishedDownloads"][id].update(self.success)
            self.json_object["failedDownloads"][id].update(self.failed)
            MyJson().write_json(musicdataFile,self.json_object)


    def downloadPlaylist(self):
        id = 'Playlists'
        # Add urls to music
        self.music = self.json_object[id].values()

        # Download options
        ydl_opts = {
            'format': 'bestaudio/best',
            'hls_prefer_native': True,
            'writethumbnail': True, 
            'outtmpl':'Audios/%(playlist_title)s/%(title)s.%(ext)s',
            #'quiet':True,# Don't print messages
            'postprocessors': [{
                'key': 'FFmpegExtractAudio',
                'preferredcodec': 'm4a',
                'preferredquality': '192',
            }],
        }
        with youtube_dl.YoutubeDL(ydl_opts) as ydl:
            while self.count < len(self.music) - 1:
                self.count+=1
                item = self.music[self.count]
                try:
                    ydl.download([item])
                    print('------------------------------------------------------------------------')
                except youtube_dl.utils.DownloadError as e:
                    self.error_handler(msg='Failed download', solution='', id=id)
                    print(e)
                except youtube_dl.utils.GeoRestrictedError as e:
                    self.error_handler(msg='This song is not available in your region', solution='', id=id)
                    print(e)
                except youtube_dl.utils.MaxDownloadsReached as e:
                    self.error_handler(msg='Sorry but you have reached your maximum downloads', solution='', id=id)
                    print(e)
                    break
                except youtube_dl.utils.UnsupportedError as e:
                    self.error_handler(msg='Unsupported', solution='', id=id)
                    print(e)
                except youtube_dl.utils.UnavailableVideoError as e:
                    self.error_handler(msg='Not available in mp3 format', solution='', id=id)
                    print(e)
                except youtube_dl.utils.YoutubeDLError as e:
                    self.error_handler(msg='FATAL YOUTUBE_DL ERROR', solution='', id=id)
                    print(e)
                except Exception as e:
                    self.error_handler(msg='ERROR UNKNOWN', solution='', id=id)
                    print(e)
                    break
            
            #1.Clear Playlists after downloading all music 2.Add to finished dwnloads and failed downloads
            self.json_object[id].clear()
            self.json_object["finishedDownloads"][id].update(self.success)
            self.json_object["failedDownloads"][id].update(self.failed)
            MyJson().write_json(musicdataFile,self.json_object)
