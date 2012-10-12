###

  Autocomplete

  This script provides functionalities for autocompleting things 
  
###

jQuery ->
  $("input.autocomplete").live "focus", (event)->
    if not $(this).hasClass("ui-autocomplete-input")
      new AutoComplete $(this)
    else if $(this).val() != ""
      $(this).autocomplete("search", $(this).val())

class AutoComplete
  
  constructor: (input_field)->
    @setup input_field
    do @delegateEvents
    
  delegateEvents: =>
    @el.bind "blur", (event)=>
      @current_ajax.abort() if @current_ajax?
  
  setup: (input_field, source)=>
    @el = $(input_field)
    @el.data("_autocomplete", @this)
    @data = @el.data()
    @el.autocomplete
      source: if source? then source else if @data.autocomplete_data? then @data.autocomplete_data else if @data.url then @remote_source
      select: @select
      focus: @focus 
    # add class name to autocomplete widget
    @el.autocomplete("widget").addClass @data.autocomplete_class
    # show on focus
    if @data.autocomplete_search_on_focus == true
      @el.bind "focus", (event)=>
        @el.autocomplete("option", "minLength", 0)
        @el.autocomplete("search", "")
        @el.autocomplete("widget").position
          of: @el
          my: "left top"
          at: "left bottom"
        window.setTimeout => 
          @el.select() if @el.is ":focus"
        , 100
    # render autocomplete item
    if @data.autocomplete_element_tmpl?
      @el.data("autocomplete")._renderItem = (ul, item)=>
        $( "<li></li>" ).data("item.autocomplete", item).append( $.tmpl(@data.autocomplete_element_tmpl, item) ).appendTo(ul)

  remote_source: (request, response)=>
    data = {format: "json", term: request.term}
    data = $.extend(true, data, {with: @data.autocomplete_with}) if @data.autocomplete_with?
    @el.autocomplete("widget").scrollTop 0
    @current_ajax.abort() if @current_ajax?
    @current_ajax = $.ajax 
      url: @data.url
      data: data
      dataType: "json"
      beforeSend: =>
        @el.next(".loading").remove()
        @el.next(".icon").hide()
        @el.after LoadingImage.get()
        @el.autocomplete("close")
      complete: =>
        @el.next(".loading").remove()
        @el.next(".icon").show()
      success: (data)=>
        # compute entries
        entries = $.map data, (element)=> 
          element.value = element[@data.autocomplete_value_attribute] if @data.autocomplete_value_attribute?
          element
        # setup autocomplete search only once & only search on focus
        if @data.autocomplete_search_only_on_focus? or @data.autocomplete_search_only_once?
          @setup @el, entries
          @el.bind "blur", ()=> @setup @el, @source  
        # return entries
        response entries

  select: (event, element)=>
    @el.val element.item[@data.autocomplete_display_attribute]
    @el.autocomplete("close")
    if @data.autocomplete_value_target?
      $(@data.autocomplete_value_target).val(element.item.value).change()
    if @data.autocomplete_select_callback?
      callback = eval @data.autocomplete_select_callback
      if callback?
        callback(element, event)
    @el.blur() if @data.autocomplete_blur_on_select == true
    return false

  focus: (event, ui)=>
    @el.val ui.item[@data.autocomplete_display_attribute]
    return false
    
window.AutoComplete = AutoComplete