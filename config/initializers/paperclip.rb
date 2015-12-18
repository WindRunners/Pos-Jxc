Paperclip.interpolates :product do |attachment, style|
  product = attachment.instance.product
  unless product.blank?
    product.id
  end
end