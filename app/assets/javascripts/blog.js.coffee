jQuery ->
# index
	$("#published_blogs").sortable
    axis: "y"
    handle: ".handle"
    update: ->
      $.post $(this).data("update-url"), $(this).sortable("serialize")

  # starts at date
	$(".blog_message_starts_at").datepicker(dateFormat: "dd-mm-yy")
	$("body").delegate ".blog_message_starts_at", "click", ->
		$(this).datepicker(dateFormat: "dd-mm-yy")

	$("body").delegate ".blog_message_starts_at", "change", ->
		$(this).closest("form").unbind('submit').submit()
		value = $(this).val()
		id_attr = $(this).parent().next().attr("id")
		id_array = id_attr.split("_")
		id = id_array[1]
		$("#message_"+id+"_starts_at_text").html(value)
		$(".blog_message_starts_at").datepicker(dateFormat: "dd-mm-yy")

	# ends at date
	$(".blog_message_ends_at").datepicker(dateFormat: "dd-mm-yy")
	$("body").delegate ".blog_message_ends_at", "click", ->
		$(this).datepicker(dateFormat: "dd-mm-yy")

	$("body").delegate ".blog_message_ends_at", "change", ->
		$(this).closest("form").unbind('submit').submit()
		value = $(this).val()
		id_attr = $(this).parent().next().attr("id")
		id_array = id_attr.split("_")
		id = id_array[1]
		$("#message_"+id+"_ends_at_text").html(value)
		$(".blog_message_ends_at").datepicker(dateFormat: "dd-mm-yy")


	# select status
	$("body").delegate ".blog_ajax_edit select", "change", ->
		$(this).closest("form").submit()

# _form
	$("#blog_starts_at").datepicker(dateFormat: "dd-mm-yy")
	$("#blog_ends_at").datepicker(dateFormat: "dd-mm-yy")
