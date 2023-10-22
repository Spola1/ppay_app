import requests
from telethon import TelegramClient, sync, events
import sys
import pdb

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

# получаем никнейм бота/пользователя
async def get_username(user_id):
    try:
        entity = await client.get_entity(user_id)
        return entity.username
    except Exception as e:
        print(f"Error getting username for user {user_id}: {e}")
        return None

@client.on(events.NewMessage(chats=chats_to_listen))
async def normal_handler(event):
    message_text = event.text
    sender_id = event.message.from_id.user_id if event.message.from_id else event.message.peer_id.user_id
    sender_username = await get_username(sender_id)

    # отправляем сообщения только от бота(исключаем сообщения реального пользователя)
    if '@' + sender_username in chats_to_listen:
        send_message_to_rails(message_text, sender_username)

def send_message_to_rails(message_text, sender):
    url = 'http://localhost:3000/api/v1/simbank/requests'
    data = {
        'message': message_text,
        'app': 'Telegram',
        'main_application_id': main_application_id,
        'telegram_phone': phone_number,
        'type': 'telegram_message',
        'from': '@' + sender
    }
    response = requests.post(url, json=data)

client.run_until_disconnected()
