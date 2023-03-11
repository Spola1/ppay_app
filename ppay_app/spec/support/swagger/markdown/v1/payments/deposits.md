## Создание депозита

Для отправки запроса нужно сформировать тело (Request body) в формате JSON со следующими параметрами:

<table>
  <thead>
    <tr>
      <th>Параметр</th>
      <th>Название</th>
      <th>Тип</th>
      <th>Наличие</th>
      <th>Описание</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>national_currency</code></td>
      <td>Национальная валюта</td>
      <td>String</td>
      <td>Обязательно</td>
      <td>Укажите валюту, в которой клиент будет вносить деньги</td>
    </tr>
    <tr>
      <td><code>national_currency_amount</code></td>
      <td>Сумма</td>
      <td>Number</td>
      <td>Обязательно</td>
      <td>Укажите сумму платежа</td>
    </tr>
    <tr>
      <td><code>external_order_id</code></td>
      <td>Внешний ID заявки</td>
      <td>String</td>
      <td>Опционально</td>
      <td>Укажите ID платежа или заявки в Вашей системе, чтобы можно было по нему отследить платёж у нас</td>
    </tr>
    <tr>
      <td><code>unique_amount</code></td>
      <td>Уникализация суммы</td>
      <td>String</td>
      <td>Опционально</td>
      <td>
        Может иметь значения: <strong>none</strong>, <strong>integer</strong>, <strong>decimal</strong>.</br>
        По умолчанию - none.</br>
        Если выбрано integer или decimal, то сумма платежа может подменена на</br>
        уникальную в случае, если в обработке у оператора уже находится другой</br>
        платеж с такой же суммой.</br>
        Integer — подменяет сумму платежа на уникальную путем уменьшения на 1 единицу валюты</br>
        (например 1000 -&gt; 999). Decimal — на 0.01 (например 1000 -&gt; 99.99)</br>
      </td>
    </tr>
    <tr>
      <td><code>redirect_url</code></td>
      <td>Ссылка на возврат в магазин</td>
      <td>String</td>
      <td>Обязательно</td>
      <td>Укажите ссылку, по которой клиент вернётся в магазин в конце оплаты</td>
    </tr>
    <tr>
      <td><code>callback_url</code></td>
      <td>Ссылка обратного вызова</td>
      <td>String</td>
      <td>Обязательно</td>
      <td>Укажите Вашу ссылку обратного вызова, для POST запросов об изменениях статуса</td>
    </tr>
  </tbody>
</table>

<br>

## Ссылка обратного вызова (callback_url)

Сервис создания депозита будет информировать Вас об изменениях статуса платежа с
помощью ссылки callback_url. По ней будет отправляться серия POST запросов (при
каждом изменении статуса) со следующей информацией.

### В заголовках (headers):

| Заголовок                              | Описание                                                               |
|----------------------------------------|------------------------------------------------------------------------|
| `Content-Type: application/json`       | Тело запроса содержит JSON объект                                      |
| `Authorization: Bearer {Ваш API-ключ}` | Ваш API ключ, для удостоверения того что запрос пришёл с нашей стороны |

<br>

### В теле запроса в формате JSON:

<table>
  <thead>
    <tr>
      <th>Параметр</th>
      <th>Название</th>
      <th>Тип</th>
      <th>Наличие</th>
      <th>Описание</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>uuid</code></td>
      <td>Идентификатор платежа</td>
      <td>String</td>
      <td>Обязательно</td>
      <td>Универсальный уникальный идентификатор платежа</td>
    </tr>
    <tr>
      <td><code>extenal_order_id</code></td>
      <td>Внешний ID заявки</td>
      <td>String</td>
      <td>Опционально</td>
      <td>ID платежа в Вашей системе</td>
    </tr>
    <tr>
      <td><code>payment_status</code></td>
      <td>Статус платежа</td>
      <td>String</td>
      <td>Обязательно</td>
      <td>
        Статус платежа. Может иметь следующие значения:
        <ul>
          <li><strong>draft</strong> — Ввод данных карты</li>
          <li><strong>processer_search</strong> — Поиск оператора</li>
          <li><strong>transferring</strong> — Перевод денег</li>
          <li><strong>confirming</strong> — Подтверждение перевода</li>
          <li><strong>completed</strong> — Успешно завершён</li>
          <li><strong>cancelled</strong> — Отменён</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><code>cancellation_reason</code></td>
      <td>Причина отмены</td>
      <td>String</td>
      <td>Опционально</td>
      <td>
        Причина отмены платежа. Может иметь следующие значения:
        <ul>
          <li><strong>by_client</strong> — Отменено клиентом</li>
          <li><strong>duplicate_payment</strong> — Задублированный платеж</li>
          <li><strong>fraud_attempt</strong> — Попытка мошенничества</li>
          <li><strong>incorrect_amount</strong> — Переведённая клиентом сумма не соответствует запрошенной</li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

#### Пример приходящего по callback_url запроса:

```
{
  "data": {
    "uuid": "8de5d972-cdbb-48c1-9afe-318c38247fa7",
    "type": "Deposit",
    "attributes": {
      "uuid": "8de5d972-cdbb-48c1-9afe-318c38247fa7",
      "external_order_id": "1234",
      "payment_status": "confirming"
    }
  }
}
```

<br>

*Для отправки тестового запроса, нажмите кнопку `Try it out`, затем внизу `Execute`*

*Предварительно можно открыть в браузере `Dev Tools (F12)` > вкладка `Network`, чтобы увидеть все данные по запросу.*
