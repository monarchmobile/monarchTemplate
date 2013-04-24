jQuery ->
	$("body").delegate ".user_ajax_edit .user_approval_status", "change", ->
		$(this).closest("form").submit ->
			return
	
	$("body").delegate ".user_ajax_edit .user_approval_status", "click", ->
		select = $(this).prev()
		if select.val() == "true"
			select.val("false")
			select.closest("form").submit()
		else if select.val() == "false"
			select.val("true")
			select.closest("form").submit()
		