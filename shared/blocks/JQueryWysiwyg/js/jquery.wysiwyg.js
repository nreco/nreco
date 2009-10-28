/**
 * WYSIWYG - jQuery plugin 0.5
 *
 * Copyright (c) 2008-2009 Juan M Martinez
 * http://plugins.jquery.com/project/jWYSIWYG
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 *
 * $Id: $
 */
(function( $ )
{
    $.fn.document = function()
    {
        var element = this[0];

        if ( element.nodeName.toLowerCase() == 'iframe' )
            return element.contentWindow.document;
            /*
            return ( $.browser.msie )
                ? document.frames[element.id].document
                : element.contentWindow.document // contentDocument;
             */
        else
            return $(this);
    };

    $.fn.documentSelection = function()
    {
        var element = this[0];

        if ( element.contentWindow.document.selection ) {
			return element.contentWindow.document.selection.createRange().text;
        } else {
			return element.contentWindow.getSelection().toString();
		}
    };

    $.fn.wysiwyg = function( options )
    {
        if ( arguments.length > 0 && arguments[0].constructor == String )
        {
            var action = arguments[0].toString();
            var params = [];

            for ( var i = 1; i < arguments.length; i++ )
                params[i - 1] = arguments[i];

            if ( action in Wysiwyg )
            {
                return this.each(function()
                {
                    $.data(this, 'wysiwyg')
                     .designMode();

                    Wysiwyg[action].apply(this, params);
                });
            }
            else return this;
        }

        var controls = {};

        /**
         * If the user set custom controls, we catch it, and merge with the
         * defaults controls later.
         */
        if ( options && options.controls )
        {
            var controls = options.controls;
            delete options.controls;
        }

        var options = $.extend({
            html : '<'+'?xml version="1.0" encoding="UTF-8"?'+'><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">STYLE_SHEET</head><body>INITIAL_CONTENT</body></html>',
            css  : {},

            debug        : false,

            autoSave     : true,  // http://code.google.com/p/jwysiwyg/issues/detail?id=11
            rmUnwantedBr : true,  // http://code.google.com/p/jwysiwyg/issues/detail?id=15
            brIE         : false,
			placeholders : { flash : 'css/jwysiwyg/flash.jpg' },
			
            controls : {},
            messages : {}
        }, options);

        options.messages = $.extend(true, options.messages, Wysiwyg.MSGS_EN);
        options.controls = $.extend(true, options.controls, Wysiwyg.TOOLBAR);

        for ( var control in controls )
        {
            if ( control in options.controls )
                $.extend(options.controls[control], controls[control]);
            else
                options.controls[control] = controls[control];
        }

        // not break the chain
        return this.each(function()
        {
            Wysiwyg(this, options);
        });
    };

    function Wysiwyg( element, options )
    {
        return this instanceof Wysiwyg
            ? this.init(element, options)
            : new Wysiwyg(element, options);
    }

    $.extend(Wysiwyg, {
        insertImage : function( szURL, attributes )
        {
            var self = $.data(this, 'wysiwyg');

            if ( self.constructor == Wysiwyg && szURL && szURL.length > 0 )
            {
                if ( attributes )
                {
                    self.editorDoc.execCommand('insertImage', false, '#jwysiwyg#');
                    var img = self.getElementByAttributeValue('img', 'src', '#jwysiwyg#');

                    if ( img )
                    {
                        img.src = szURL;

                        for ( var attribute in attributes )
                        {
                            img.setAttribute(attribute, attributes[attribute]);
                        }
                    }
                }
                else
                {
					$(self.editorDoc.body).focus();
                    
					if (szURL.substr( szURL.length-4)==".swf") {
						// flash
						var flashHtml = '<img src="'+self.options.placeholders.flash+'?'+escape(szURL)+'" width="100" height="100" />';
						Wysiwyg["insertHtml"].apply(this, [flashHtml]);
					} else {
						// usual image
						if (!$.browser.msie || !self.lastRange) {
							self.editorDoc.execCommand('InsertImage', false, szURL);
						} else {
							self.lastRange.pasteHTML('<img src="'+szURL+'">');
						}
						self.saveContent();
					}
					
                }
            }
        },
		
		insertHtml : function(htmlContent)
		{
			var self = $.data(this, 'wysiwyg');
			if ( self.constructor == Wysiwyg) {
				$(self.editorDoc.body).focus();
				if (!$.browser.msie)
					self.editorDoc.execCommand('inserthtml', false, htmlContent);
				else {
					var rng = self.lastRange ? self.lastRange : self.getRange();
					rng.pasteHTML(htmlContent);
				}
				self.saveContent();				
			}
		},
		
        createLink : function( szURL, title )
        {
            var self = $.data(this, 'wysiwyg');

            if ( self.constructor == Wysiwyg && szURL && szURL.length > 0 )
            {
                var selection = $(self.editor).documentSelection();
				// also check panel selection
				var isPanelActive = $.browser.mozilla && self.panel.find(".active").length>0;
                if ( selection.length > 0 || isPanelActive)
                {
                    $(self.editorDoc.body).focus();
					self.editorDoc.execCommand('unlink', false, []);
                    self.editorDoc.execCommand('createLink', false, szURL);
					self.saveContent();
                }
                else if (title) {
					$(self.editorDoc.body).focus();
					if (!$.browser.msie)
						self.editorDoc.execCommand('inserthtml', false, '<a href="'+szURL+'">'+title+'</a>');
					else {
						var rng = self.lastRange ? self.lastRange : self.getRange();
						rng.pasteHTML('<a href="'+szURL+'">'+title+'</a>');
					}
					self.saveContent();
				} else if ( self.options.messages.nonSelection )
                    alert(self.options.messages.nonSelection);
            }
        },

        setContent : function( newContent )
        {
            var self = $.data(this, 'wysiwyg');
                self.setContent( newContent );
                self.saveContent();
        },

        clear : function()
        {
            var self = $.data(this, 'wysiwyg');
                self.setContent('');
                self.saveContent();
        },

        MSGS_EN : {
            nonSelection : 'select the text you wish to link'
        },

        TOOLBAR : {
            bold          : { visible : true, tags : ['b', 'strong'], css : { fontWeight : 'bold' } },
            italic        : { visible : true, tags : ['i', 'em'], css : { fontStyle : 'italic' } },
            strikeThrough : { visible : false, tags : ['s', 'strike'], css : { textDecoration : 'line-through' } },
            underline     : { visible : false, tags : ['u'], css : { textDecoration : 'underline' } },

            separator00 : { visible : false, separator : true },

            justifyLeft   : { visible : false, css : { textAlign : 'left' } },
            justifyCenter : { visible : false, tags : ['center'], css : { textAlign : 'center' } },
            justifyRight  : { visible : false, css : { textAlign : 'right' } },
            justifyFull   : { visible : false, css : { textAlign : 'justify' } },

            separator01 : { visible : false, separator : true },

            indent  : { visible : false },
            outdent : { visible : false },

            separator02 : { visible : false, separator : true },

            subscript   : { visible : false, tags : ['sub'] },
            superscript : { visible : false, tags : ['sup'] },

            separator03 : { visible : false, separator : true },

            undo : { visible : false },
            redo : { visible : false },

            separator04 : { visible : false, separator : true },

            insertOrderedList    : { visible : false, tags : ['ol'] },
            insertUnorderedList  : { visible : false, tags : ['ul'] },
            insertHorizontalRule : { visible : false, tags : ['hr'] },

            separator05 : { separator : true },

            createLink : {
                visible : true,
                exec    : function()
                {
                    var selection = $(this.editor).documentSelection();

                    if ( selection.length > 0 )
                    {
                        if ( $.browser.msie )
                            this.editorDoc.execCommand('createLink', true, null);
                        else
                        {
                            var szURL = prompt('URL', 'http://');

                            if ( szURL && szURL.length > 0 )
                            {
                                this.editorDoc.execCommand('unlink', false, []);
                                this.editorDoc.execCommand('createLink', false, szURL);
                            }
                        }
                    }
                    else if ( this.options.messages.nonSelection )
                        alert(this.options.messages.nonSelection);
                },

                tags : ['a']
            },

            insertImage : {
                visible : true,
                exec    : function()
                {
                    if ( $.browser.msie )
                        this.editorDoc.execCommand('insertImage', true, null);
                    else
                    {
                        var szURL = prompt('URL', 'http://');

                        if ( szURL && szURL.length > 0 )
                            this.editorDoc.execCommand('insertImage', false, szURL);
                    }
                },

                tags : ['img']
            },

            separator06 : { separator : true },

            h1mozilla : { visible : true && $.browser.mozilla, className : 'h1', command : 'heading', arguments : ['h1'], tags : ['h1'] },
            h2mozilla : { visible : true && $.browser.mozilla, className : 'h2', command : 'heading', arguments : ['h2'], tags : ['h2'] },
            h3mozilla : { visible : true && $.browser.mozilla, className : 'h3', command : 'heading', arguments : ['h3'], tags : ['h3'] },

            h1 : { visible : true && !( $.browser.mozilla ), className : 'h1', command : 'formatBlock', arguments : '<H1>', tags : ['h1'] },
            h2 : { visible : true && !( $.browser.mozilla ), className : 'h2', command : 'formatBlock', arguments : '<H2>', tags : ['h2'] },
            h3 : { visible : true && !( $.browser.mozilla ), className : 'h3', command : 'formatBlock', arguments : '<H3>', tags : ['h3'] },

            separator07 : { visible : false, separator : true },

            cut   : { visible : false },
            copy  : { visible : false },
            paste : { visible : false },

            separator08 : { separator : true && !( $.browser.msie ) },

            setFontSize : { 
				visible : true, 
				exec : function(size) 
				{ 
					this.editorDoc.execCommand('FontSize', false, size);
					this.saveContent();
				},
				init : function(self, item, exec) {
					item.find("a").append(
						'<div class="fontSizeSelector"><a href="javascript:void(0)" size="-2"><font size="-2">A-2</font></a><a href="javascript:void(0)" size="-1"><font size="-1">A-1</font></a><a href="javascript:void(0)" size="+0"><font size="+0">A</font></a><a href="javascript:void(0)" size="+1"><font size="+1">A+1</font></a><a href="javascript:void(0)" size="+2"><font size="+2">A+2</font></a><a href="javascript:void(0)" size="+3"><font size="+3">A+3</font></a><a href="javascript:void(0)" size="+4"><font size="+4">A+4</font></a></div>'
					).find("a").click( function() {
						exec.apply(self, [$(this).attr("size")] );
						//alert( $(this).attr("size") );
					});
					item.hover( function() {
						item.find(".fontSizeSelector").show();
					}, function() {
						item.find(".fontSizeSelector").hide();
					});
					
				}
			},
            setFontColor : {
				visible : true, 
				exec : function(color, isBackground) 
				{ 
					if (isBackground) {
						if ($.browser.msie)
							this.editorDoc.execCommand('BackColor', false, color);
						else
							this.editorDoc.execCommand('hilitecolor',false,color);
					} else
						this.editorDoc.execCommand('ForeColor', false, color);
					this.saveContent();
				},
				init : function(self, item, exec) {
					var colors = [
							'#ffffff','#d0d0d0','#777777','#000000', // monochromes
							'#ffaaaa','#ff00ff', '#ff0000','#aa0000','#9000ff', // reds
							'#ff6c00', '#ffff00', '#ffbb00', '#f0e68c','#d2b229', // browns/oranges/yellows
							'#aaffaa','#00ff00','#00aa00','#6b8e23','#007700', // greens
							'#bbddff','#00ffdd', '#aaaaff','#0000ff','#0000aa' // blues
					];
					var colorsHtml = "";
					for (var cIdx = 0; cIdx<colors.length; cIdx++) {
						var previewForeFix = cIdx>0 ? "" : ";background-color:#E0E0E0";
						colorsHtml += '<div class="color"><a href="javascript:void(0)" color="'+colors[cIdx]+'" class="ForeColor" style="color:'+colors[cIdx]+previewForeFix+'">ABC</a><a href="javascript:void(0)" color="'+colors[cIdx]+'" class="BackColor" style="background-color:'+colors[cIdx]+'">ABC</a></div>';
					}
					
					var $fontSelectionBox = $('<div class="fontColorSelector">'+colorsHtml+'</div>');
					item.find("a").append($fontSelectionBox);
					$fontSelectionBox.find("a.ForeColor").click( function() {
						exec.apply(self, [$(this).attr("color")] );
					});
					$fontSelectionBox.find("a.BackColor").click( function() {
						exec.apply(self, [$(this).attr("color"),true] );
					});
					item.hover( function() {
						item.find(".fontColorSelector").show();
					}, function() {
						item.find(".fontColorSelector").hide();
					});
					
				}
			},
			
            separator09 : { separator : true },

            html : {
                visible : false,
                exec    : function()
                {
                    if ( this.viewHTML )
                    {
                        this.setContent( $(this.original).val() );
                        $(this.original).hide();
                    }
                    else
                    {
                        this.saveContent();
                        $(this.original).show();
                    }

                    this.viewHTML = !( this.viewHTML );
                }
            },

            removeFormat : {
                visible : true,
                exec    : function()
                {
                    if ($.browser.mozilla) {
						this.editorDoc.execCommand('heading', false, ['p']);
					} else {
						this.editorDoc.execCommand('formatBlock', false, '<p>');
					}
					this.editorDoc.execCommand('removeFormat', false, []);
                    this.editorDoc.execCommand('unlink', false, []);
					this.saveContent();
                }
            }
        }
    });

    $.extend(Wysiwyg.prototype,
    {
        original : null,
        options  : {},

        element  : null,
        editor   : null,

        init : function( element, options )
        {
            var self = this;

            this.editor = element;
            this.options = options || {};

            $.data(element, 'wysiwyg', this);

            var newX = element.width || element.clientWidth;
            var newY = element.height || element.clientHeight;

            if ( element.nodeName.toLowerCase() == 'textarea' )
            {
                this.original = element;

                if ( newX == 0 && element.cols )
                    newX = ( element.cols * 8 ) + 21;

                if ( newY == 0 && element.rows )
                    newY = ( element.rows * 16 ) + 16;

                var editor = this.editor = $('<iframe FRAMEBORDER="0" MARGINWIDTH="0" MARGINHEIGHT="0"></iframe>').css({
                    minHeight : ( newY - 6 ).toString() + 'px',
                    width     : ( newX - 8 ).toString() + 'px'
                }).attr('id', $(element).attr('id') + 'IFrame');

                /**
                 * http://code.google.com/p/jwysiwyg/issues/detail?id=96
                 */
                this.editor.attr('tabindex', $(element).attr('tabindex'));

                if ( $.browser.msie )
                {
                    this.editor
                        .css('height', ( newY ).toString() + 'px');

                    /**
                    var editor = $('<span></span>').css({
                        width     : ( newX - 6 ).toString() + 'px',
                        height    : ( newY - 8 ).toString() + 'px'
                    }).attr('id', $(element).attr('id') + 'IFrame');

                    editor.outerHTML = this.editor.outerHTML;
                     */
                }
            }

            var panel = this.panel = $('<ul></ul>').addClass('panel');

            this.appendControls();
			var estimatedWidth = ( newX > 0 ) ? ( newX ).toString() + 'px' : '100%';
            this.element = $('<div></div>').css({
                width : estimatedWidth
            }).addClass('wysiwyg')
              .append(panel)
              .append( $('<div><!-- --></div>').css({ clear : 'both' }) )
              .append(editor);
			
            $(element)
            // .css('display', 'none')
            .hide()
            .before(this.element);
			
			if (this.options.resizable)
				this.element.resizable( { 
					alsoResize : 'iframe', 
					maxWidth : $(this.element).width(),
					minHeight: $(this.element).height(),
					start : function(event, ui) {
						$(this).find('iframe').hide();
						$(this).addClass('jwysiwyg-resizing');
					},
					stop : function(event, ui) {
						$(this).find('iframe').show();
						$(this).removeClass('jwysiwyg-resizing');
					}
				} );			

            this.viewHTML = false;
            this.initialHeight = newY - 8;

            /**
             * @link http://code.google.com/p/jwysiwyg/issues/detail?id=52
             */
			// process placeholders
			this.initialContent = this.prepareWysiwygContent( $(element).val() );
			
            this.initFrame();

            if ( this.initialContent.length == 0 )
                this.setContent('');

            /**
             * http://code.google.com/p/jwysiwyg/issues/detail?id=100
             */
            var form = $(element).parents('form:first');

            if ( this.options.autoSave )
                $(form).submit(function() { self.saveContent(); });
			
            $(form).bind('reset', function()
            {
                self.setContent( self.initialContent );
                self.saveContent();
            });
        },
		
		prepareWysiwygContent : function(content) {
			var initialContentDom = $("<div></div>").html(content);
            var flashPlaceholder = this.options.placeholders.flash;
			initialContentDom.find('object').each( function() {
				var objElem = $(this);
				var flashUrl = null;
				// 1. try to find 'param'
				objElem.find('param').each( function() {
					if ($(this).attr("name")=="movie")
						flashUrl = $(this).attr("value");
				});
				// 2. try to find 'embed' tag
				if (flashUrl==null)
					objElem.find('embed').each( function() {
						if ($(this).attr("type")=="application/x-shockwave-flash")
							flashUrl = $(this).attr("src");
					});
				// 3. try to match using regex
				if (flashUrl==null) {
					var flashHtml = objElem.html();
					if (/type=['"]{0,1}application\/x-shockwave-flash/.test(flashHtml) ) {
						var matchedUrl = flashHtml.match(/src=['"][^'"]*/);
						if (matchedUrl) {
							matchedUrl = matchedUrl.toString().substr(4);
							if (/['"]/.test(matchedUrl.substr(0,1)) )
								flashUrl = matchedUrl.substr(1);
						}
					}
				}
				if (flashUrl!=null) {
					var flashWidth = parseInt( objElem.attr("width") ) ? objElem.attr("width") : 100;
					var flashHeight = parseInt( objElem.attr("height") ) ? objElem.attr("height") : 100;
					objElem.replaceWith('<img src="'+flashPlaceholder+'?'+escape(flashUrl)+'" width="'+flashWidth+'" height="'+flashHeight+'">');
				}
			});
			
			return initialContentDom.html();			
		},

        initFrame : function()
        {
            var self = this;
            var style = '';

            /**
             * @link http://code.google.com/p/jwysiwyg/issues/detail?id=14
             */
            if ( this.options.css && this.options.css.constructor == String )
                style = '<link rel="stylesheet" type="text/css" media="screen" href="' + this.options.css + '" />';

            this.editorDoc = $(this.editor).document();
            this.editorDoc_designMode = false;

            try {
                this.editorDoc.designMode = 'on';
                this.editorDoc_designMode = true;
            } catch ( e ) {
                // Will fail on Gecko if the editor is placed in an hidden container element
                // The design mode will be set ones the editor is focused

                $(this.editorDoc).focus(function()
                {
                    self.designMode();
                });
            }

            this.editorDoc.open();
            this.editorDoc.write(
                this.options.html
                    .replace(/INITIAL_CONTENT/, this.initialContent)
                    .replace(/STYLE_SHEET/, style)
            );
            this.editorDoc.close();
            this.editorDoc.contentEditable = 'true';

            if ( $.browser.msie )
            {
                /**
                 * Remove the horrible border it has on IE.
                 */
                setTimeout(function() { $(self.editorDoc.body).css('border', 'none'); }, 0);
            }

            $(this.editorDoc).click(function( event )
            {
                self.checkTargets( event.target ? event.target : event.srcElement);
            });

            /**
             * @link http://code.google.com/p/jwysiwyg/issues/detail?id=20
             */
            $(this.original).focus(function()
            {
                $(self.editorDoc.body).focus();
            });

            if ( this.options.autoSave )
            {
                /**
                 * @link http://code.google.com/p/jwysiwyg/issues/detail?id=11
                 */
                $(this.editorDoc).keydown(function() { self.saveContent(); })
                                 .keyup(function() { self.saveContent(); })
                                 .mouseup(function() { self.saveContent(); });
            }

            if ( this.options.css )
            {
                setTimeout(function()
                {
                    if ( self.options.css.constructor == String )
                    {
                        /**
                         * $(self.editorDoc)
                         * .find('head')
                         * .append(
                         *     $('<link rel="stylesheet" type="text/css" media="screen" />')
                         *     .attr('href', self.options.css)
                         * );
                         */
                    }
                    else
                        $(self.editorDoc).find('body').css(self.options.css);
                }, 0);
            }

            $(this.editorDoc).keydown(function( event )
            {
                if ( $.browser.msie && self.options.brIE && event.keyCode == 13 )
                {
					var rng = self.getRange();
                        rng.pasteHTML('<br />');
                        rng.collapse(false);
                        rng.select();

    				return false;
                }
				if ( $.browser.msie) {
					self.lastRange = self.getRange();
				}
            }).click( function(event) {
				if ( $.browser.msie) {
					self.lastRange = self.getRange();
				}			
			});
        },

        designMode : function()
        {
            if ( !( this.editorDoc_designMode ) )
            {
                try {
                    this.editorDoc.designMode = 'on';
                    this.editorDoc_designMode = true;
                } catch ( e ) {}
            }
        },

        getSelection : function()
        {
            return ( window.getSelection ) ? window.getSelection() : document.selection;
        },

        getRange : function()
        {
            var selection = this.getSelection();

            if ( !( selection ) )
                return null;

            return ( selection.rangeCount > 0 ) ? selection.getRangeAt(0) : selection.createRange();
        },

        getContent : function()
        {
            return $( $(this.editor).document() ).find('body').html();
        },

        setContent : function( newContent )
        {
            $( $(this.editor).document() ).find('body').html( this.prepareWysiwygContent( newContent ) );
        },

        saveContent : function()
        {
            if ( this.original )
            {
                var content = this.getContent();
				
				if (this.prevSavedContent == content)
					return; // optimization
				this.prevSavedContent = content;
				
                if ( this.options.rmUnwantedBr )
                    content = ( content.substr(-4) == '<br>' ) ? content.substr(0, content.length - 4) : content;
				
				// convert flash placeholders to SWF objects
				var contentDom = $("<div></div").html(content);
				var flashPlaceholder = this.options.placeholders.flash;
				
				contentDom.find("img").each( function() {
					var img = $(this);
					if (img.attr("src").indexOf(flashPlaceholder+"?")>=0) {
						var flashUrl = unescape( img.attr("src").substr( img.attr("src").indexOf("?")+1) );
						
						var flashWidth =  parseInt( img.css("width").replace(/px/,'') ) ? img.css("width").replace(/px/,'') : 100;
						var flashHeight = parseInt( img.css("height").replace(/px/,'') ) ? img.css("height").replace(/px/,'') : 100;
						if ($.browser.msie) {
							if ( parseInt( img.attr("width") ) )
								flashWidth = img.attr("width");
							if ( parseInt( img.attr("height") ) )
								flashHeight = img.attr("height");
						}
						
						img.replaceWith(
							'<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,28,0" width="'+flashWidth+'" height="'+flashHeight+'"><param name="movie" value="'+flashUrl+'"><param name="quality" value="high"><embed src="'+flashUrl+'" quality="high" pluginspage="http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash" type="application/x-shockwave-flash" width="'+flashWidth+'" height="'+flashHeight+'"></embed></object>'
						);
					}
				});
				
                $(this.original).val( contentDom.html() );
				
            }
        },

        appendMenu : function( cmd, args, className, fn, fnItemInit )
        {
            var self = this;
            var args = args || [];

            var item = $('<li></li>').append(
                $('<a class="icon"><!-- --></a>').addClass(className || cmd)
            ).mousedown(function() {
                if ( fn ) fn.apply(self); else self.editorDoc.execCommand(cmd, false, args);
                if ( self.options.autoSave ) self.saveContent();
            });
			if (fnItemInit)
				fnItemInit(self,item,fn);
			item.appendTo( this.panel );
        },

        appendMenuSeparator : function()
        {
            $('<li class="separator"></li>').appendTo( this.panel );
        },

        appendControls : function()
        {
            for ( var name in this.options.controls )
            {
                var control = this.options.controls[name];

                if ( control.separator )
                {
                    if ( control.visible !== false )
                        this.appendMenuSeparator();
                }
                else if ( control.visible )
                {
                    this.appendMenu(
                        control.command || name, control.arguments || [],
                        control.className || control.command || name || 'empty', control.exec, control.init
                    );
                }
            }
        },

        checkTargets : function( element )
        {
            for ( var name in this.options.controls )
            {
                var control = this.options.controls[name];
                var className = control.className || control.command || name || 'empty';

                $('.' + className, this.panel).removeClass('active');

                if ( control.tags )
                {
                    var elm = element;

                    do {
                        if ( elm.nodeType != 1 )
                            break;

                        if ( $.inArray(elm.tagName.toLowerCase(), control.tags) != -1 )
                            $('.' + className, this.panel).addClass('active');
                    } while ( elm = elm.parentNode );
                }

                if ( control.css )
                {
                    var elm = $(element);

                    do {
                        if ( elm[0].nodeType != 1 )
                            break;

                        for ( var cssProperty in control.css )
                            if ( elm.css(cssProperty).toString().toLowerCase() == control.css[cssProperty] )
                                $('.' + className, this.panel).addClass('active');
                    } while ( elm = elm.parent() );
                }
            }
        },

        getElementByAttributeValue : function( tagName, attributeName, attributeValue )
        {
            var elements = this.editorDoc.getElementsByTagName(tagName);

            for ( var i = 0; i < elements.length; i++ )
            {
                var value = elements[i].getAttribute(attributeName);

                if ( $.browser.msie )
                {
                    /** IE add full path, so I check by the last chars. */
                    value = value.substr(value.length - attributeValue.length);
                }

                if ( value == attributeValue )
                    return elements[i];
            }

            return false;
        }
    });
})(jQuery);