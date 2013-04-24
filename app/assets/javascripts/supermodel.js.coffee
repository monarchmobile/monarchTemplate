jQuery ->
	$("#visible_supermodels").sortable
		axis: "y"
		handle: '.handle'
		update: ->
			$.post $(this).data("update-url"), $(this).sortable("serialize")

	$("body").delegate "form.supermodel_ajax_edit input", "click", ->
		$(this).closest("form").submit()


