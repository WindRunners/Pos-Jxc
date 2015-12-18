json.data do
  json.array! @category.childs.reverse, :text, :type, :id, :additionalParameters
end