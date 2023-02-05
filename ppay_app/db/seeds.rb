# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
ExchangePortal.create(name: 'Binance P2P')
u1 = Admin.create(email: 'admin@test.com', password: '1234567890', nickname: 'SuperAdmin', role: 'superadmin',
                  name: 'Анатолий')
u2 = Merchant.create(email: 'merchant@test.com', password: '1234567890', nickname: 'AvangardBet', name: 'Петр Петрович')
u3 = Processer.create(email: 'processer1@test.com', password: '1234567890', nickname: 'VasiaBTC', name: 'Вася')
u4 = Processer.create(email: 'processer2@test.com', password: '1234567890', nickname: 'IvanCrypto', name: 'Ваня')
pp = Ppay.create(email: 'ppay@test.com', password: '1234567890', nickname: 'PPay_acc', name: 'Ppay')

u1 = User.find_by(email: 'admin@test.com')
u1.usdt_trc20_address = 'SaK2GZoEtevoAJq3NwhDbLyJDfjW73SSUt'
u1.save
u2 = User.find_by(email: 'merchant@test.com')
u2.usdt_trc20_address = 'ZtK2GioEtevoAJq3NwQDbLyJDfjW7AAAUt'
u2.save
u3 = User.find_by(email: 'processer1@test.com')
u3.usdt_trc20_address = 'x212GZvEteYoAJq3NIpDbLyJDfjW73KKUt'
u3.save
u4 = User.find_by(email: 'processer2@test.com')
u4.usdt_trc20_address = 'SguJGZoEtevoAJq3NwXX1LyJDfjs99Pe2v'
u4.save
