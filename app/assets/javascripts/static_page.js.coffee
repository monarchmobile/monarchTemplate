jQuery ->
	$(".super_tables").click ->
		list = $(this).next()
		if list.is(":visible")
			list.addClass("hidden")
		else if list.is(":hidden")
			list.removeClass("hidden")