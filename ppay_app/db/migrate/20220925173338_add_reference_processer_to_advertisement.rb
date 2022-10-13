class AddReferenceProcesserToAdvertisement < ActiveRecord::Migration[7.0]
  def change
    add_reference :advertisements, :processer
  end
end
