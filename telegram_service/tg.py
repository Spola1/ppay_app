import requests
from telethon import TelegramClient, sync, events
import sys

api_id = int(sys.argv[1])
api_hash = sys.argv[2]
session_name = sys.argv[3]
main_application_id = sys.argv[4]
phone_number = sys.argv[5]
telegram_bots = sys.argv[6]
telegram_bots_list = telegram_bots.split('@')
telegram_bots_list = [bot for bot in telegram_bots_list if bot]

client = TelegramClient(session_name, api_id, api_hash)

chats_to_listen = ['@' + bot for bot in telegram_bots_list]

client.start()

@client.on(events.NewMessage(chats=chats_to_listen))
async def normal_handler(event):
    message_text = event.text
    send_message_to_rails(message_text)

def send_message_to_rails(message_text):
    url = 'http://localhost:3000/api/v1/simbank/requests'
    data = {
        'message': message_text,
        'app': 'Telegram',
        'main_application_id': main_application_id,
        'telegram_phone': phone_number,
        'type': 'telegram_message',
        'from': 'Telegram'
    }
    response = requests.post(url, json=data)

client.run_until_disconnected()
