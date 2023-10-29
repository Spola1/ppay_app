import requests
from telethon import TelegramClient, sync, events
import sys
import os
import asyncio

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

simbank_api_url = os.environ.get('MAIN_APP_SIMBANK_API_URL')
status_update_url = os.environ.get('MAIN_APP_STATUS_CONNECTION_URL')

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

    if '@' + sender_username in chats_to_listen:
        send_message_to_rails(message_text, sender_username)

def send_message_to_rails(message_text, sender):
    data = {
        'message': message_text,
        'app': 'Telegram',
        'main_application_id': main_application_id,
        'telegram_phone': phone_number,
        'type': 'telegram_message',
        'from': '@' + sender
    }
    try:
        response = requests.post(simbank_api_url, json=data)
        print(f"Message sent to Rails. Response: {response.text}")
    except Exception as e:
        print(f"Error sending message to Rails: {e}")

async def check_connection_status():
    while True:
        await asyncio.sleep(10)
        try:
            # Пробуем отправить тестовое сообщение
            test_message = await client.send_message('me', 'Check connection')

            # Если сообщение успешно отправлено, удаляем его
            await client.delete_messages('me', test_message.id)
            
            print("Message delivered successfully.")

            # Отправляем статус только при успешной доставке тестового сообщения
            data = {
                'status': 'success',
                'main_application_id': main_application_id,
            }
            response = requests.post(status_update_url, json=data)
            print(f"Status update sent. Response: {response.text}")

        except Exception as e:
            print(f"Error sending test message: {e}")
            print("Connection lost.")
            break

if __name__ == "__main__":
    client.start()
    asyncio.ensure_future(check_connection_status())
    client.run_until_disconnected()