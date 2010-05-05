$(document).ready(function() {  
  $('div.facet a.show_more').click(function(ev){
    ev.preventDefault();
    $(this).parents('ul').find('li.hidden').removeClass('hidden');
    $(this).parent().addClass('hidden');
  });
  
  $('input[name=q]').autoComplete({
    ajax: '/autocomplete.json', 
    minChars: 3,
    preventEnterSubmit: false
  });
});