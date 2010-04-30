$(document).ready(function() {  
  $('div.facet a.show_more').click(function(ev){
    ev.preventDefault();
    $(this).parents('ul').find('li.hidden').removeClass('hidden');
    $(this).parent().addClass('hidden');
  });
  
  $('div.num_found').delay(5000).fadeOut();
});