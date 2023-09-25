import requests
from telethon import TelegramClient, sync, events
import sys

api_id = int(sys.argv[1])
api_hash = sys.argv[2]
session_name = sys.argv[3]

client = TelegramClient(session_name, api_id, api_hash)

chats_to_listen = ['@bot_ppay_bot']

client.start()

@client.on(events.NewMessage(chats=chats_to_listen))
async def normal_handler(event):
    message_text = event.text
    print(event.text)
    send_message_to_rails(message_text)

def send_message_to_rails(message_text):
    url = 'http://localhost:3000/api/v1/simbank/requests'
    data = {
        'message': message_text
    }
    response = requests.post(url, json=data)

    print(response.status_code)

    if response.status_code == 201:
        print('Сообщение успешно отправлено в Rails-приложение')
    else:
        print('Ошибка при отправке сообщения в Rails-приложение')

client.run_until_disconnected()
