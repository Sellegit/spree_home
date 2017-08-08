// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/backend/all.js'
	window.home_config = {}
	window.home_setup = function(home_id, parent_id){
		home_config['home_id'] = home_id
		home_config['parent_id'] = parent_id
	}	

jQuery(function(){
	var $home_content = $("#spree_home_item_content")
			$item_list =$("#spree_home_item_list"),
			RData = [],
			modules = {
				m1: '<li class="list-group-item clearfix"><span class="icon icon-move"></span>Top Banner <button type="button" class="btn">Edit</button><button type="button" class="btn btn-danger module-delete">Delete</button></li>',
				m5: '<li class="list-group-item first clearfix"><span></span><div>New Arrivals Feed<div>（Note：Every Time Loading 25 Products）</div></div><div><button type="button" class="btn btn-sm btn-danger module-delete">Delete</button></div></li>'
			}
	$(".add-home-module").on('click', function(){
		var mid = $(this).data('moduleid'), url, data;

		url = '/admin/homes/' + home_config['home_id']+'/home_items';
		data = {item: {module_type: mid, parent_id: home_config['parent_id']}};
		$.ajax({
			type: 'POST',
			url: url,
			data: data,
			success: function(data){
				if(!data.status){
					if(mid == 5){
						alert('This only add one')
						return ;
					}
					alert(data.msg)
				}else{
					window.location.reload()
				}

			},
			complete: function(){
			}
		}).fail(function(){
			alert('Error')
		})
	})


	$home_content.on('click','.module-delete', function(){
		var  $this = $(this),
					url = '/admin/homes/'+ home_config['home_id'] + '/home_items/' + $this.data('id') + '/delete';

		$this.text('Deleting').prop('disabled', true);

		$.ajax({
			type: 'POST',
			url: url,
			data: {}
		}).done(function(data){
			location.reload()
		}).fail(function(){
			alert("Error")
		}).always(function(){
			$this.text('Delete').prop('disabled', false);
		})

	})

	$(".add-carousel").on('click', function(){
		var $this = $(this),
				url = '/admin/homes/'+ $this.data('homeid') + '/home_items/' +  $this.data('id') + '/add';
		$this.text('Adding').prop('disabled', true)		
		$.ajax({
			type: 'POST',
			url: url,
			data: { }
		}).done(function(data){
			location.reload()
		}).fail(function(){
			alert("Error")
		}).always(function(){
			$this.text('Add').prop('disabled', false)
		})
	})

	$("#publish").on('click', function(){
		var $this = $(this), url;
		url = '/admin/homes/' + $this.data('homeid') +'/publish'
		$this.text('Publishing').prop('disabled', true);
		$.post({
			type: 'POST',
			url: url,
		}).done(function(data){
			if(!data.status){
				alert(data.msg)
			}
		}).fail(function(){
			alert('error')
		}).always(function(){
			$this.text('Publish').prop('disabled', false);
		})
	})

	function hadNewArraival(){
		var last = RData[RData.length - 1];
		return last && last['m5'];
	}

	// Fix sortable helper
  var fixHelper = function(e, ui) {
      ui.children().each(function() {
          $(this).width($(this).width());
      });
      return ui;
  };

  $('table.home-sortable').ready(function(){
    var td_count = $(this).find('tbody tr:first-child td').length
    $('table.home-sortable tbody').sortable(
      {
        handle: '.handle',
        helper: fixHelper,
        placeholder: 'ui-sortable-placeholder',
        update: function(event, ui) {
          var tbody = this;
          $("#progress").show();
          positions = {};
          $.each($('tr', tbody), function(position, obj){
            reg = /spree_(\w+_?)+_(\d+)/;
            parts = reg.exec($(obj).prop('id'));
            if (parts) {
              positions['positions['+parts[2]+']'] = position+1;
            }
          });
          $.ajax({
            type: 'POST',
            dataType: 'script',
            url: '/admin/homes/home_items/update_order',
            data: positions,
            success: function(data){ $("#progress").hide(); }
          });
        },
        start: function (event, ui) {
          // Set correct height for placehoder (from dragged tr)
          ui.placeholder.height(ui.item.height())
          // Fix placeholder content to make it correct width
          ui.placeholder.html("<td colspan='"+(td_count-1)+"'></td><td class='actions'></td>")
        },
        stop: function (event, ui) {
          // Fix odd/even classes after reorder
          $("table.sortable tr:even").removeClass("odd even").addClass("even");
          $("table.sortable tr:odd").removeClass("odd even").addClass("odd");
        }

      });
	});

	$('#spree_home_item_list').sortable(
		{
			items: 'li.first',
			handle: '.icon-move',
			helper: fixHelper,
			update: function(event, ui) {
				var tbody = this, 
						positions = {}, 
						$arrival = $("#spree_home_item_list li.arrival"),
						$orders = $("#spree_home_item_list li.first");

				$("#progress").show();
				
				$.each($orders, function(position, obj){
					var id  = $(obj).data('id');
					positions['positions['+ id +']'] = position+1;
				});

				if($arrival.length){
					positions['positions['+ $arrival.data('id') +']'] = $orders.size() + 2;
				}

				$.ajax({
					type: 'POST',
					dataType: 'script',
					url: '/admin/homes/home_items/update_order',
					data: positions,
					success: function(data){ $("#progress").hide(); }
				});
			},
		});
		$('.list-group-item-text').sortable(
		{
			items: '.taxon',
			handle: '.handle',
			helper: fixHelper,
			update: function(event, ui) {
				var tbody = this, 
						positions = {},
						$orders = $(this).find('.taxon');

				$("#progress").show();
				
				$.each($orders, function(position, obj){
					var id  = $(obj).data('id');
					positions['positions['+ id +']'] = position+1;
				});
				$.ajax({
					type: 'POST',
					dataType: 'script',
					url: '/admin/homes/home_items/update_order',
					data: positions,
					success: function(data){ $("#progress").hide(); }
				});
			},
		});

		$('.list-group-item-text').sortable(
		{
			items: '.carousel',
			handle: '.handle',
			helper: fixHelper,
			update: function(event, ui) {
				var tbody = this, 
						positions = {},
						$orders = $(this).find('.carousel');

				$("#progress").show();
				
				$.each($orders, function(position, obj){
					var id  = $(obj).data('id');
					positions['positions['+ id +']'] = position+1;
				});
				$.ajax({
					type: 'POST',
					dataType: 'script',
					url: '/admin/homes/home_items/update_order',
					data: positions,
					success: function(data){ $("#progress").hide(); }
				});
			},
		});
})
	


