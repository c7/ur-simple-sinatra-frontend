$(document).ready(function() {  
  $('div.facet a.show_more').click(function(ev){
    ev.preventDefault();
    $(this).parents('ul').find('li.hidden').removeClass('hidden');
    $(this).parent().addClass('hidden');
  });
  
  $("a.remove_facet_filter").text('');
  $("a.remove_facet_filter").hover(
    function(){$(this).parent().css('background-color', '#f7f7f7');},
    function(){$(this).parent().css('background-color', '#fff');}
  );
  
  $("h4.expandable").click(function(e) {
    $(this).toggleClass(function() {
      
      if ($(this).hasClass('expanded')) { 
        $(this).next().slideUp();
      } else {
        $(this).next().slideDown();
      }
      
      return 'expanded';
    });
  });
});