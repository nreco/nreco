/*
* UI Query Builder Plugin
* uiQueryBuilder is a jQuery plug-in that allows composing and editing abstract query.
* @version 0.1
* @author Vitaliy Fedorchenko http://code.google.com/p/nreco/wiki/uiQueryBuilder
* 
* Dual licensed under the MIT and GPL licenses:
* http://www.opensource.org/licenses/mit-license.php
* http://www.gnu.org/licenses/gpl.html
*/

(function($) {

	$.fn.uiQueryBuilder = function(settings) {
		var settings = $.extend({}, $.fn.uiQueryBuilder.defaults, settings);
	
		this.each(function() {
			var $t = $(this);
			init($(this), settings);
		});
		
		function init(k, o) {
			var $container = k;
			$container.addClass('uiQueryBuilderContainer');
			var $conditionContainer = $('<div class="uiQueryBuilderConditionContainer"/>');
			$container.append($conditionContainer);
			
			$container.data(
				'reset', 
				function() {
					$conditionContainer.find('.uiQueryBuilderConditionRow').each(function() { removeRow($conditionContainer, o, $(this)); });
					addRow($conditionContainer, o);
				}
			);
			$container.data(
				'addConditions', 
				function(conditions) {
					//remove empty row
					$conditionContainer.find(".uiQueryBuilderConditionRow.empty").each(function() {
						removeRow($conditionContainer, o, $(this));
					});
				
					for (var idx=0; idx<conditions.length; idx++) {
						var fldData = findArrayObjByProp(o.fields, 'name', conditions[idx].field);
						if (fldData!=null)
							addRow($conditionContainer, o, conditions[idx]);
					}
					//add empty row at the end
					addRow($conditionContainer, o);
				}
			);
			$container.data(
				'getConditions',
				function() {
					return getConditions($conditionContainer,o);
				}
			);
						
			if (o.showExpressionSelector) {
				var $expressionContainer = $('<div class="uiQueryBuilderExpressionContainer"/>');
				$container.append($expressionContainer);
				addExpressionTypeSelector($expressionContainer,o,$conditionContainer);
				
				var baseOnRowAdded = o.onRowAdded;
				o.onRowAdded = function($row) {
					refreshExpressionCustomInput($expressionContainer, o, getConditions($conditionContainer, o), true );
					baseOnRowAdded($row);
				};
				var baseOnRowRemoved = o.onRowRemoved;
				o.onRowRemoved = function($row) {
					refreshExpressionCustomInput($expressionContainer, o, getConditions($conditionContainer, o) );
					baseOnRowRemoved($row);
				};				
				
				$container.data(
					'getExpression',
					function() {
						var exprTypeValue = $expressionContainer.find('select.expressionTypeSelector').val();
						var exprType = findArrayObjByProp(o.expressionTypes, 'value', exprTypeValue);
						if (!exprType.showInput)
							refreshExpressionCustomInput($expressionContainer, o, getConditions($conditionContainer, o) );
						var customExprInput = $expressionContainer.find('input.customExpression').val();
						return {
							type : exprTypeValue,
							expression : customExprInput
						};
					}
				);
				$container.data(
					'setExpression',
					function(exprTypeValue, customExpression) {
						var exprType = findArrayObjByProp(o.expressionTypes, 'value', exprTypeValue);
						$expressionContainer.find('select.expressionTypeSelector').val(exprTypeValue).change();
						if (exprType.showInput) {
							$expressionContainer.find('input.customExpression').val(customExpression);
						} 
					}
				);				
			}			
			
			addRow($conditionContainer, o);
		}
		
		function refreshExpressionCustomInput($expressionContainer, config, currentConditions, isRowAdded) {
			isRowAdded = isRowAdded ? true : false;
			var currentExprTypeValue = $expressionContainer.find('select.expressionTypeSelector').val();
			var exprType = findArrayObjByProp(config.expressionTypes, 'value', currentExprTypeValue);
			var cIndexes = [];
			for (var cIdx=0; cIdx<currentConditions.length; cIdx++)
				cIndexes[cIdx] = cIdx+1;
			var $customExprInput = $expressionContainer.find('input.customExpression');
			$customExprInput.val( 
				exprType.generateExpression(currentConditions,cIndexes, $customExprInput.val(), isRowAdded ) );
		}
		
		function getConditions($container, config) {
			var conditions = [];
			$container.find(".uiQueryBuilderConditionRow").each(function() {
				var $row = $(this);
				if (!$row.hasClass('empty')) {
					var fieldName = $row.find('.uiQueryBuilderFieldSelector select').val();
					var fldData = findArrayObjByProp(config.fields, 'name', fieldName);
					var renderer = findArrayObjByProp(config.renderers, 'name', fldData.renderer.name);

					conditions.push( {
						field : fieldName,
						condition : $row.find('.uiQueryBuilderConditionSelector select').val(),
						value : renderer.getValue( $row.find('.uiQueryBuilderValue') )
					});
				}
			});	
			return conditions;		
		}
		
		function addExpressionTypeSelector($container, config, $conditionContainer) {
			var $select = $('<select class="expressionTypeSelector"/>');
			for (var exprIdx=0; exprIdx<config.expressionTypes.length; exprIdx++) {
				var exprType = config.expressionTypes[exprIdx];
				$select.append( $('<option>').attr('value',exprType.value).html( exprType.text ) );
			}
			$container.append($select);
			var $textBox = $('<input type="text" class="customExpression"/>');
			if (config.expressionTypes.length>0)
				setVisible($textBox, config.expressionTypes[0].showInput);
			$container.append($textBox);
			
			$select.change(function() {
				var newExprTypeValue = $(this).val();
				var exprType = findArrayObjByProp(config.expressionTypes, 'value', newExprTypeValue);
				setVisible($textBox, exprType.showInput);
				
				refreshExpressionCustomInput($container,config, getConditions($conditionContainer, config) );
			});
		}
		
		function setVisible($elem, flag) {
			if (flag) 
				$elem.show();
			else
				$elem.hide();
		}
		
		function addRow($container, config, defaultState) {
			var $row = $("<div class='uiQueryBuilderConditionRow'><span class='rowIndex'></span></div>");
			$container.append($row);
			
			var $fldSelectorContainer = renderFieldSelector(config);
			$row.append($fldSelectorContainer);
			var $fldSelector = $fldSelectorContainer.find('select');
			$fldSelector.change(function() {
				var $select = $(this);
				var $row = $select.parents('.uiQueryBuilderConditionRow');
				if ($select.val()=="") {
					removeRow($container,config,$row);
				} else {
					$row.removeClass("empty");
					$row.find('.uiQueryBuilderConditionSelector,.uiQueryBuilderValue').remove();
					
					var $conditionSelectorContainer = renderFieldCondition(config,$select.val() );
					$row.append($conditionSelectorContainer);
					
					var $valueSelector = renderFieldValue(config,$select.val(), void(0) ,$row, $conditionSelectorContainer);
					//$row.append($valueSelector);
				}
				//add empty row
				if ($container.find(".uiQueryBuilderConditionRow.empty").length==0)
					addRow($container,config);
			});
			// set default state
			if (typeof(defaultState)!='undefined') {
				var fldData = findArrayObjByProp(config.fields, 'name', defaultState.field);
				if (fldData!=null) {
					$fldSelector.val(defaultState.field);
					
					var $conditionSelectorContainer = renderFieldCondition(config,defaultState.field,defaultState.condition);
					$row.append($conditionSelectorContainer);
					
					var $valueSelector = renderFieldValue(config,defaultState.field,defaultState.value,$row,$conditionSelectorContainer);
					//$row.append($valueSelector);
				}
			} else {
				$row.addClass("empty");
			}
			
			//$container.append($row);
			refreshRowIndexes($container, config);
			config.onRowAdded($row);
		}
		
		function removeRow($container, config, $row) {
			$row.addClass('empty');
			$row.remove();
			refreshRowIndexes($container, config);
			config.onRowRemoved($row);
		}
		
		function refreshRowIndexes($container, config) {
			if (!config.showRowIndex)
				return;
			var index = 1;
			$container.find('.uiQueryBuilderConditionRow').each(function() {
				$(this).find('.rowIndex').html(index);
				index++;
			});
		}
		
		function renderFieldSelector(config) {
			var $select = $('<select/>');
			$select.append( $('<option value="">').html( config.notSelectedFieldText ) );
			for (var fldIdx=0; fldIdx<config.fields.length; fldIdx++) {
				var fldData = config.fields[fldIdx];
				$select.append( $('<option>').attr('value',fldData.name).html( fldData.caption ) );
			}
			var $selectHolder = $('<span class="uiQueryBuilderFieldSelector"></span>');
			$selectHolder.append($select);
			return $selectHolder;
		}
		
		function findArrayObjByProp(arr, propName, propValue) {
			for (var arrIdx=0; arrIdx<arr.length; arrIdx++)
				if (arr[arrIdx][propName]==propValue)
					return arr[arrIdx];
			return null;
		} 
		
		function renderFieldValue(config, fieldName, defaultValue, row, conditionSelectorContainer) {
			var fldData = findArrayObjByProp(config.fields, 'name', fieldName);
			var renderer = findArrayObjByProp(config.renderers, 'name', fldData.renderer.name);
			var placeHolder = $('<span class="uiQueryBuilderValue"/>');
			row.append(placeHolder);
			var html = renderer.render({config:config,field:fldData,defaultValue:defaultValue,placeHolder:placeHolder,condition:conditionSelectorContainer.find('select').val() });
			if (html) {
				placeHolder.append( html );
			}
			
			if (conditionSelectorContainer && typeof(renderer.renderOnConditionChange)=='boolean' && renderer.renderOnConditionChange) {
				conditionSelectorContainer.find('select').change(function() { 
					renderFieldValue(config, fieldName, renderer.getValue(placeHolder), row);
				});
			}			
			return placeHolder;
		}
		
		function renderFieldCondition(config, fieldName, defaultValue) {
			var $select = $('<select/>');
			var fldData = findArrayObjByProp(config.fields, 'name', fieldName);
			if (typeof(fldData.conditions)!='undefined' && fldData.conditions!=null)
				for (var cIdx=0; cIdx<fldData.conditions.length; cIdx++) {
					var cData = fldData.conditions[cIdx];
					$select.append( $('<option>').attr('value',cData.value).html( cData.text ) );
				}
			if (typeof(defaultValue)!='undefined') {
				$select.val(defaultValue);
			}
			var $selectHolder = $('<span class="uiQueryBuilderConditionSelector"></span>');
			$selectHolder.append($select);
			return $selectHolder;
		}
		
		
	};
	
	//Default configuration:
	$.fn.uiQueryBuilder.defaults = {
		renderers : [
			{
				name: "textbox",
				render : function(c) {
					var config = c.config;
					var fieldData = c.field;
					var defaultValue = c.defaultValue;				
					var $textbox = $('<input type="text"/>');
					if (typeof(defaultValue)!='undefined') {
						$textbox.val(defaultValue);
					}
					return $textbox;
				},
				getValue : function($valueContainer) {
					return $valueContainer.find('input').val();
				}
			},
			{
				name : "dropdownlist",
				render : function(c) {
					var config = c.config;
					var fieldData = c.field;
					var defaultValue = c.defaultValue;
					var $select = $('<select/>');
					var selectData
					if (typeof(fieldData.renderer.values)!='undefined') {
						for (var valIdx=0; valIdx<fieldData.renderer['values'].length; valIdx++) {
							var vData = fieldData.renderer['values'][valIdx];
							$select.append( $('<option>').attr('value',vData.value).html( vData.text ) );						
						}
						if (typeof(defaultValue)!='undefined') {
							$select.val(defaultValue);
						}				
					} else if (typeof(fieldData.renderer.getValues)=='function') {
						fieldData.renderer.getValues(function(values) {
							for (var valIdx=0; valIdx<values.length; valIdx++) {
								var vData = values[valIdx];
								$select.append( $('<option>').attr('value',vData.value).html( vData.text ) );						
							}
							if (typeof(defaultValue)!='undefined') {
								$select.val(defaultValue);
							}														
						});
						
					}
					return $select;
				},
				getValue : function($valueContainer) {
					return $valueContainer.find('select').val();
				}				
			}
		],
		expressionTypes : [
			{
				value : 'all',
				text : 'Include all of the above',
				showInput : false,
				generateExpression : function(conditions, condIndexes) {
					return condIndexes.join(" and ");
				}
			},
			{
				value : 'any',
				text : 'Include any of the above',
				showInput : false,
				generateExpression : function(conditions, condIndexes) {
					return condIndexes.join(" or ");
				}
			},
			{
				value : 'custom',
				text : 'Custom condition',
				showInput : true,
				generateExpression : function(conditions, condIndexes, currentExpression, isRowAdded) {
					if (isRowAdded && conditions.length>1 && $.trim(currentExpression)!='')
						return currentExpression + " and "+conditions.length;
					else
						return condIndexes.join(" and ");
				}
			}
		],
		fields : [],
		notSelectedFieldText : '-- select --',
		showRowIndex : true,
		showExpressionSelector : true,
		onRowAdded  : function($row) { },
		onRowRemoved  : function($row) { }
	};
	
	//Current version:
	$.fn.uiQueryBuilder.version = 0.1;

})(jQuery);
