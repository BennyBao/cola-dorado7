class cola.AbstractItemGroup extends cola.Widget
	@ATTRIBUTES:
		items:
			setter: (value)->
				@clearItems()
				@addItem(item) for item in value
				return @
		currentIndex:
			defaultValue: -1
			setter: (value)->
				@setCurrentIndex(value)
				return @

	constructor: (config) ->
		@_items = []
		super(config)

	getContentContainer: ()->
		return @getDom()
	getItems: ()->
		return @_items
	getItemDom: (item)->
		itemConfig = item
		if typeof item is "number"
			itemConfig = @_items[item]

		if itemConfig instanceof cola.Widget
			itemDom = itemConfig.getDom()
		else if itemConfig.nodeType == 1
			itemDom = itemConfig

		return itemDom

	_addItemToDom: (item)->
		container = @getContentContainer()
		itemDom = @getItemDom(item)
		container.appendChild(itemDom) if itemDom.parentNode isnt container
		return

	_itemsRender: ()->
		return unless @_items
		@_addItemToDom(item) for item in @_items
		return

	setCurrentIndex: (index)->
		@_currentIndex ?= -1
		return @ if @_currentIndex == index
		if @_currentIndex > -1
			oldItemDom = @getItemDom(@_currentIndex)
			$(oldItemDom).removeClass("active") if oldItemDom
		if index > -1
			newItemDom = @getItemDom(index)
			$(newItemDom).addClass("active") if newItemDom
		@_currentIndex = index
		return @

	_doOnItemsChange: ()->
		cola.util.delay(@, "_refreshItems", 50, @refreshItems)
		return

	refreshItems: ()->
		cola.util.cancelDelay(@, "_refreshItems")
		return @

	addItem: (config)->
		if config.constructor == Object.prototype.constructor
			active = config.active
			delete config.active
			if config.$type
				item = cola.widget(config)
			else
				item = $.xCreate(config)

		else if config.nodeType == 1
			active = cola.util.hasClass(config, "active")
			item = cola.widget(config)
			item ?= config

		return @ unless item
		return @ if @_items.indexOf(item) > -1
		@_items.push(item)
		@_addItemToDom(item)
		@setCurrentIndex(@_items.indexOf(item)) if !!active
		@_doOnItemsChange()
		return @

	clearItems: ()->
		@_items ?= []
		return @ if @_items.length == 0

		for item in @_items
			if item instanceof cola.Widget
				item.destroy()
			else
				$(item).remove()
		@_items = []
		@_doOnItemsChange()
		return @

	removeItem: (item)->
		if typeof item is "number"
			itemObj = @_items[item]
			index = item
		else
			itemObj = item
			index = @_items.indexOf(item)

		@_items.splice(index, 1)

		if itemObj instanceof cola.Widget
			itemObj.destroy()
		else
			$(itemObj).remove()
		@_doOnItemsChange()
		return @

	destroy: ()->
		@clearItems()
		delete @_items
		super()

