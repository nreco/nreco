/*
* jSquared
* jSquared is a jQuery plug-in that enables ability to add/remove table columns and rows like in Google Squared UI.
* @version 0.1
* @author Vitaliy Fedorchenko http://code.google.com/p/nreco/wiki/JSquared
* 
* Dual licensed under the MIT and GPL licenses:
* http://www.opensource.org/licenses/mit-license.php
* http://www.gnu.org/licenses/gpl.html
*/

(function($) {

	$.fn.jSquared = function(settings) {
		var settings = $.extend({}, $.fn.jSquared.defaults, settings);
	
		this.each(function() {
			var $t = $(this);
			init($(this), settings);
		});
		
		function init(k, o) {
			var $t = k;
			$t.addClass('jSquaredTable');
			// if no header row at all, lets create 'top-left' empty cell
			if ($t.find('tr:first th').length==0)
				$t.append('<tr><th class="jSquaredTopLeft">'+o.topLeftCellText+'</th></tr>');
			else {
				// initialize existing columns (style, remove)
				$t.find('tr:first').find('th:not(:first)').each( function() {
					var $h = $(this);
					var text = $h.html();
					$newH = $( renderColumnHeader(text,o) );
					$newH.insertBefore( $h ); 
					$h.remove();
					registerColCellHandlers($newH,o);
				});
			}
			// initialize rows
			$t.find('tr:not(:first)').find('td:first').each( function() {
				var $h = $(this);
				var text = $h.html();
				$newH = $( renderRowHeader(text,o) );
				$newH.insertBefore( $h ); 
				$h.remove();
				registerRowCellHandlers($newH,o);
			});
			
			// add extra column - header
			$t.find('tr').find('th:last').after('<th class="jSquaredAddCol"><input type="text"/><a href="javascript:void(0)">'+o.addColumnText+'</a></th>');
			// and fix existing rows!
			$t.find('tr:not(:first)').find('td:last').after('<td></td>');
			
			// add extra row
			var cols = $t.find('tr th').length;
			
			$t.find('tr:last').after('<tr><td class="jSquaredAddRow"><input type="text"/><a href="javascript:void(0)">'+o.addRowText+'</a></td><td class="jSquaredColspan" colspan="'+(cols-1)+'"></td></tr>');
			// handlers
			$t.find('.jSquaredAddCol a').click( function() { onAddCol($(this).parents('th:first'), o); } );
			$t.find('.jSquaredAddCol input').keydown( function(e) { if (e.keyCode==13) { onAddCol( $(this).parents('th:first'), o); return false;} });
			$t.find('.jSquaredAddRow a').click( function() { onAddRow( $(this).parents('td:first'), o); } )
			$t.find('.jSquaredAddRow input').keydown( function(e) { if (e.keyCode==13) { onAddRow( $(this).parents('td:first'), o); return false;} });;
		}
		function onRemoveCol(cell, o) {
			var $t = cell.parents('table.jSquaredTable:first');
			var idx = cell.parents('tr:first').find('th').index(cell);
			o.onRowRemoving(cell);
			$t.find('tr:first').find('th:eq('+idx+')').remove();
			$t.find('tr:not(:last)').find('td:eq('+idx+')').remove();
			fixLastRow($t);
		}
		function renderColumnHeader(text, o) {
			return '<th class="jSquaredColumnText"><span class="text">'+text+'</span><a class="jSquaredColumnRemove" href="javascript:void(0)">'+o.removeRowText+'</a></th>';
		}
		function fixLastRow(t) {
			// fix cell for last row
			var colCount = t.find('tr th').length;
			t.find('tr:last td.jSquaredColspan').attr('colspan', colCount-1);
		}
		function registerColCellHandlers(cell,o) {
			cell.find('a.jSquaredColumnRemove').click( function() { onRemoveCol( $(this).parents('th:first'), o);	});
		}
		function onAddCol(cell, o) {
			var $t = cell.parents('table.jSquaredTable:first');
			var $addTh = cell;
			var $input = $addTh.find('input');
			var text = $input.val();
			if (text=='')
				return;			
			var thIndex = $addTh.parents('tr:first').find('th').index($addTh);
			// render col header
			var $newTh = $(renderColumnHeader(text,o));
			$newTh.insertBefore( $addTh.parents('tr:first').find('th:eq('+thIndex+')') );
			registerColCellHandlers($newTh,o);
			// render cells
			$t.find('tr:not(:first):not(:last)').each( function() {
				$(this).find('td:eq('+thIndex+')').before('<td>'+o.loadingContent+'</td>');
			});
			fixLastRow($t);
			
			if (o.clearInputAfterAdd)
				$input.val('').focus();
				
			o.onColumnAdded($newTh, text, $t.find('tr:not(:last)').find('td:eq('+thIndex+')') );
		}
		function registerRowCellHandlers(cell,o) {
			cell.find('a.jSquaredRowRemove').click( function() { onRemoveRow( $(this).parents('td'), o); });
		}		
		function renderRowHeader(text, o) {
			return '<td class="jSquaredRowText"><span class="text">'+text+'</span><a class="jSquaredRowRemove" href="javascript:void(0)">'+o.removeColumnText+'</a></td>';
		}
		function onAddRow(cell, o) {
			var $t = cell.parents('table.jSquaredTable:first');
			var $addTr = cell.parents('tr:first');
			var $input = cell.find('input');
			var text = $input.val();
			if (text=='')
				return;
			// render row
			var colCnt = $t.find('tr th').length;
			var cells = '';
			for (var cellIdx=0; cellIdx<(colCnt-1); cellIdx++)
				cells += '<td>'+(cellIdx==(colCnt-2) ? '' : o.loadingContent) +'</td>';
			var $newRow = $('<tr>'+renderRowHeader(text,o)+cells+'</tr>');
			registerRowCellHandlers($newRow.find('td.jSquaredRowText'),o);
			$newRow.insertBefore($addTr);
			if (o.clearInputAfterAdd)
				$input.val('').focus();
			
			o.onRowAdded($newRow.find('.jSquaredRowText'), text, $newRow.find('td:not(.jSquaredRowText):not(:last)') );
		}
		function onRemoveRow(cell, o) {
			var $t = cell.parents('table.jSquaredTable:first');
			o.onColumnRemoving(cell);
			cell.parents('tr:first').remove();
		}
		
		
	};
	
	//Default configuration:
	$.fn.jSquared.defaults = {
		addColumnText : 'Add',
		addRowText : 'Add',
		removeColumnText : '[x]',
		removeRowText : '[x]',
		topLeftCellText : '',
		clearInputAfterAdd : true,
		onRowAdded  : function(textCell, text, dataCells) { } ,
		onColumnAdded  : function(textCell, text, dataCells) { },
		onColumnRemoving : function(textCell) { },
		onRowRemoving : function(textCell) { },
		loadingContent : 'loading...'
	};
	
	//Current version:
	$.fn.jSquared.version = 0.1;

})(jQuery);
