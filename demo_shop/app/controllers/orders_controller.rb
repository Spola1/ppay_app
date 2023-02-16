class OrdersController < ApplicationController
  include HTTParty
  include Rails.application.routes.url_helpers

  def index
    @orders = current_user.orders
  end

  def create
    order = Order.find(params[:order_id])
    line_items = []
    order_cost = 0
    line_item_cost = 0
    order.line_items.each do |item|
      line_item_cost = item.product.price_cents * item.quantity
      order_cost += line_item_cost
      line_item_cost = 0
      line_items << {
        name: item.product.name,
        amount: item.product.price_cents,
        images: [item.product.photos.first.url],
        currency: 'RUB',
        quantity: item.quantity
      }
    end

    order.amount_cents = order_cost

    @result = HTTParty.post("http://localhost:3000/api/v1/payments/deposits", 
      :body => { :national_currency => 'RUB', 
                 :national_currency_amount => order.amount_cents,
                 :external_order_id => order.id,
                 :redirect_url => "http://localhost:3001/orders/#{order.id}/success",
                 :callback_url => "http://localhost:3001/orders/#{order.id}/callback"
               },
      :headers => { 'Accept' => 'application/json',
                    'Authorization' => "Bearer 4aa0e37e403ac40f3ee9cdf1c9b2c703aacde017df65bb4e"
                   } )

    order.url = @result.parsed_response["url"]
    order.uuid = @result.parsed_response["uuid"]


    order.save

    redirect_to "/users/#{current_user.id}/orders/#{order.id}"
  end

  def update_quantity
    current_order = current_user.orders.where(status: 'pending').first
    current_line_item = LineItem.find(product_params[:id])
    current_line_item.quantity = product_params["line_items"]["quantity"].to_i
    current_line_item.save
    redirect_to order_path(current_order)
  end

  def show
    @current_order = current_user.orders.where(status: 'pending').last
    @order = Order.find(params[:id])
    render :current_order unless params.key?(:user_id)
  end

  def order_completed
    @order = Order.find(params[:order_id])
    @order.status = 'completed'
    @order.save
    @shipping_address = retrieve_shipping_address(@order.checkout_session_id)
  end

  def success
    @order = Order.find(params[:order_id])
  end

  def order_failed
    @order = Order.find(params[:order_id])
    flash[:notice] = "Payment failed. Please try again."
    redirect_to order_url(params[:order_id])
  end

  def callback
    order_id = params[:order_id]
    payment_status = params[:payment_status]

    # Обновляем статус заказа в соответствии с данными из запроса
    @order = Order.find_by(id: order_id)
    if @order
      @order.update(status: payment_status)
      render plain: "Order status updated successfully"
    else
      render plain: "Order not found", status: :unprocessable_entity
    end
  end

  private

  def product_params
    params.require(:line_item).permit(:id, line_items: [:quantity])
  end

  def retrieve_shipping_address(checkout_session_id)
    session = Stripe::Checkout::Session.retrieve(checkout_session_id)
    session.shipping
  end
end
