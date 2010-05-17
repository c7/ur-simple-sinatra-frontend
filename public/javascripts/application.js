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
  
  $("a.remove_facet_filter").text('');
  
  $("a.remove_facet_filter").hover(
    function(){$(this).parent().css('background-color', '#f7f7f7');},
    function(){$(this).parent().css('background-color', '#fff');}
  );
  
  $("a[rel^=prettyPhoto]").prettyPhoto({theme:'dark_rounded'});
});