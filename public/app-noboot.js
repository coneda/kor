(function(global, factory) {
    if (typeof define === "function" && define.amd) define(function() {
        return factory(global);
    }); else factory(global);
})(this, function(window) {
    var Zepto = function() {
        var undefined, key, $, classList, emptyArray = [], concat = emptyArray.concat, filter = emptyArray.filter, slice = emptyArray.slice, document = window.document, elementDisplay = {}, classCache = {}, cssNumber = {
            "column-count": 1,
            columns: 1,
            "font-weight": 1,
            "line-height": 1,
            opacity: 1,
            "z-index": 1,
            zoom: 1
        }, fragmentRE = /^\s*<(\w+|!)[^>]*>/, singleTagRE = /^<(\w+)\s*\/?>(?:<\/\1>|)$/, tagExpanderRE = /<(?!area|br|col|embed|hr|img|input|link|meta|param)(([\w:]+)[^>]*)\/>/gi, rootNodeRE = /^(?:body|html)$/i, capitalRE = /([A-Z])/g, methodAttributes = [ "val", "css", "html", "text", "data", "width", "height", "offset" ], adjacencyOperators = [ "after", "prepend", "before", "append" ], table = document.createElement("table"), tableRow = document.createElement("tr"), containers = {
            tr: document.createElement("tbody"),
            tbody: table,
            thead: table,
            tfoot: table,
            td: tableRow,
            th: tableRow,
            "*": document.createElement("div")
        }, readyRE = /complete|loaded|interactive/, simpleSelectorRE = /^[\w-]*$/, class2type = {}, toString = class2type.toString, zepto = {}, camelize, uniq, tempParent = document.createElement("div"), propMap = {
            tabindex: "tabIndex",
            readonly: "readOnly",
            "for": "htmlFor",
            "class": "className",
            maxlength: "maxLength",
            cellspacing: "cellSpacing",
            cellpadding: "cellPadding",
            rowspan: "rowSpan",
            colspan: "colSpan",
            usemap: "useMap",
            frameborder: "frameBorder",
            contenteditable: "contentEditable"
        }, isArray = Array.isArray || function(object) {
            return object instanceof Array;
        };
        zepto.matches = function(element, selector) {
            if (!selector || !element || element.nodeType !== 1) return false;
            var matchesSelector = element.matches || element.webkitMatchesSelector || element.mozMatchesSelector || element.oMatchesSelector || element.matchesSelector;
            if (matchesSelector) return matchesSelector.call(element, selector);
            var match, parent = element.parentNode, temp = !parent;
            if (temp) (parent = tempParent).appendChild(element);
            match = ~zepto.qsa(parent, selector).indexOf(element);
            temp && tempParent.removeChild(element);
            return match;
        };
        function type(obj) {
            return obj == null ? String(obj) : class2type[toString.call(obj)] || "object";
        }
        function isFunction(value) {
            return type(value) == "function";
        }
        function isWindow(obj) {
            return obj != null && obj == obj.window;
        }
        function isDocument(obj) {
            return obj != null && obj.nodeType == obj.DOCUMENT_NODE;
        }
        function isObject(obj) {
            return type(obj) == "object";
        }
        function isPlainObject(obj) {
            return isObject(obj) && !isWindow(obj) && Object.getPrototypeOf(obj) == Object.prototype;
        }
        function likeArray(obj) {
            var length = !!obj && "length" in obj && obj.length, type = $.type(obj);
            return "function" != type && !isWindow(obj) && ("array" == type || length === 0 || typeof length == "number" && length > 0 && length - 1 in obj);
        }
        function compact(array) {
            return filter.call(array, function(item) {
                return item != null;
            });
        }
        function flatten(array) {
            return array.length > 0 ? $.fn.concat.apply([], array) : array;
        }
        camelize = function(str) {
            return str.replace(/-+(.)?/g, function(match, chr) {
                return chr ? chr.toUpperCase() : "";
            });
        };
        function dasherize(str) {
            return str.replace(/::/g, "/").replace(/([A-Z]+)([A-Z][a-z])/g, "$1_$2").replace(/([a-z\d])([A-Z])/g, "$1_$2").replace(/_/g, "-").toLowerCase();
        }
        uniq = function(array) {
            return filter.call(array, function(item, idx) {
                return array.indexOf(item) == idx;
            });
        };
        function classRE(name) {
            return name in classCache ? classCache[name] : classCache[name] = new RegExp("(^|\\s)" + name + "(\\s|$)");
        }
        function maybeAddPx(name, value) {
            return typeof value == "number" && !cssNumber[dasherize(name)] ? value + "px" : value;
        }
        function defaultDisplay(nodeName) {
            var element, display;
            if (!elementDisplay[nodeName]) {
                element = document.createElement(nodeName);
                document.body.appendChild(element);
                display = getComputedStyle(element, "").getPropertyValue("display");
                element.parentNode.removeChild(element);
                display == "none" && (display = "block");
                elementDisplay[nodeName] = display;
            }
            return elementDisplay[nodeName];
        }
        function children(element) {
            return "children" in element ? slice.call(element.children) : $.map(element.childNodes, function(node) {
                if (node.nodeType == 1) return node;
            });
        }
        function Z(dom, selector) {
            var i, len = dom ? dom.length : 0;
            for (i = 0; i < len; i++) this[i] = dom[i];
            this.length = len;
            this.selector = selector || "";
        }
        zepto.fragment = function(html, name, properties) {
            var dom, nodes, container;
            if (singleTagRE.test(html)) dom = $(document.createElement(RegExp.$1));
            if (!dom) {
                if (html.replace) html = html.replace(tagExpanderRE, "<$1></$2>");
                if (name === undefined) name = fragmentRE.test(html) && RegExp.$1;
                if (!(name in containers)) name = "*";
                container = containers[name];
                container.innerHTML = "" + html;
                dom = $.each(slice.call(container.childNodes), function() {
                    container.removeChild(this);
                });
            }
            if (isPlainObject(properties)) {
                nodes = $(dom);
                $.each(properties, function(key, value) {
                    if (methodAttributes.indexOf(key) > -1) nodes[key](value); else nodes.attr(key, value);
                });
            }
            return dom;
        };
        zepto.Z = function(dom, selector) {
            return new Z(dom, selector);
        };
        zepto.isZ = function(object) {
            return object instanceof zepto.Z;
        };
        zepto.init = function(selector, context) {
            var dom;
            if (!selector) return zepto.Z(); else if (typeof selector == "string") {
                selector = selector.trim();
                if (selector[0] == "<" && fragmentRE.test(selector)) dom = zepto.fragment(selector, RegExp.$1, context), 
                selector = null; else if (context !== undefined) return $(context).find(selector); else dom = zepto.qsa(document, selector);
            } else if (isFunction(selector)) return $(document).ready(selector); else if (zepto.isZ(selector)) return selector; else {
                if (isArray(selector)) dom = compact(selector); else if (isObject(selector)) dom = [ selector ], 
                selector = null; else if (fragmentRE.test(selector)) dom = zepto.fragment(selector.trim(), RegExp.$1, context), 
                selector = null; else if (context !== undefined) return $(context).find(selector); else dom = zepto.qsa(document, selector);
            }
            return zepto.Z(dom, selector);
        };
        $ = function(selector, context) {
            return zepto.init(selector, context);
        };
        function extend(target, source, deep) {
            for (key in source) if (deep && (isPlainObject(source[key]) || isArray(source[key]))) {
                if (isPlainObject(source[key]) && !isPlainObject(target[key])) target[key] = {};
                if (isArray(source[key]) && !isArray(target[key])) target[key] = [];
                extend(target[key], source[key], deep);
            } else if (source[key] !== undefined) target[key] = source[key];
        }
        $.extend = function(target) {
            var deep, args = slice.call(arguments, 1);
            if (typeof target == "boolean") {
                deep = target;
                target = args.shift();
            }
            args.forEach(function(arg) {
                extend(target, arg, deep);
            });
            return target;
        };
        zepto.qsa = function(element, selector) {
            var found, maybeID = selector[0] == "#", maybeClass = !maybeID && selector[0] == ".", nameOnly = maybeID || maybeClass ? selector.slice(1) : selector, isSimple = simpleSelectorRE.test(nameOnly);
            return element.getElementById && isSimple && maybeID ? (found = element.getElementById(nameOnly)) ? [ found ] : [] : element.nodeType !== 1 && element.nodeType !== 9 && element.nodeType !== 11 ? [] : slice.call(isSimple && !maybeID && element.getElementsByClassName ? maybeClass ? element.getElementsByClassName(nameOnly) : element.getElementsByTagName(selector) : element.querySelectorAll(selector));
        };
        function filtered(nodes, selector) {
            return selector == null ? $(nodes) : $(nodes).filter(selector);
        }
        $.contains = document.documentElement.contains ? function(parent, node) {
            return parent !== node && parent.contains(node);
        } : function(parent, node) {
            while (node && (node = node.parentNode)) if (node === parent) return true;
            return false;
        };
        function funcArg(context, arg, idx, payload) {
            return isFunction(arg) ? arg.call(context, idx, payload) : arg;
        }
        function setAttribute(node, name, value) {
            value == null ? node.removeAttribute(name) : node.setAttribute(name, value);
        }
        function className(node, value) {
            var klass = node.className || "", svg = klass && klass.baseVal !== undefined;
            if (value === undefined) return svg ? klass.baseVal : klass;
            svg ? klass.baseVal = value : node.className = value;
        }
        function deserializeValue(value) {
            try {
                return value ? value == "true" || (value == "false" ? false : value == "null" ? null : +value + "" == value ? +value : /^[\[\{]/.test(value) ? $.parseJSON(value) : value) : value;
            } catch (e) {
                return value;
            }
        }
        $.type = type;
        $.isFunction = isFunction;
        $.isWindow = isWindow;
        $.isArray = isArray;
        $.isPlainObject = isPlainObject;
        $.isEmptyObject = function(obj) {
            var name;
            for (name in obj) return false;
            return true;
        };
        $.isNumeric = function(val) {
            var num = Number(val), type = typeof val;
            return val != null && type != "boolean" && (type != "string" || val.length) && !isNaN(num) && isFinite(num) || false;
        };
        $.inArray = function(elem, array, i) {
            return emptyArray.indexOf.call(array, elem, i);
        };
        $.camelCase = camelize;
        $.trim = function(str) {
            return str == null ? "" : String.prototype.trim.call(str);
        };
        $.uuid = 0;
        $.support = {};
        $.expr = {};
        $.noop = function() {};
        $.map = function(elements, callback) {
            var value, values = [], i, key;
            if (likeArray(elements)) for (i = 0; i < elements.length; i++) {
                value = callback(elements[i], i);
                if (value != null) values.push(value);
            } else for (key in elements) {
                value = callback(elements[key], key);
                if (value != null) values.push(value);
            }
            return flatten(values);
        };
        $.each = function(elements, callback) {
            var i, key;
            if (likeArray(elements)) {
                for (i = 0; i < elements.length; i++) if (callback.call(elements[i], i, elements[i]) === false) return elements;
            } else {
                for (key in elements) if (callback.call(elements[key], key, elements[key]) === false) return elements;
            }
            return elements;
        };
        $.grep = function(elements, callback) {
            return filter.call(elements, callback);
        };
        if (window.JSON) $.parseJSON = JSON.parse;
        $.each("Boolean Number String Function Array Date RegExp Object Error".split(" "), function(i, name) {
            class2type["[object " + name + "]"] = name.toLowerCase();
        });
        $.fn = {
            constructor: zepto.Z,
            length: 0,
            forEach: emptyArray.forEach,
            reduce: emptyArray.reduce,
            push: emptyArray.push,
            sort: emptyArray.sort,
            splice: emptyArray.splice,
            indexOf: emptyArray.indexOf,
            concat: function() {
                var i, value, args = [];
                for (i = 0; i < arguments.length; i++) {
                    value = arguments[i];
                    args[i] = zepto.isZ(value) ? value.toArray() : value;
                }
                return concat.apply(zepto.isZ(this) ? this.toArray() : this, args);
            },
            map: function(fn) {
                return $($.map(this, function(el, i) {
                    return fn.call(el, i, el);
                }));
            },
            slice: function() {
                return $(slice.apply(this, arguments));
            },
            ready: function(callback) {
                if (readyRE.test(document.readyState) && document.body) callback($); else document.addEventListener("DOMContentLoaded", function() {
                    callback($);
                }, false);
                return this;
            },
            get: function(idx) {
                return idx === undefined ? slice.call(this) : this[idx >= 0 ? idx : idx + this.length];
            },
            toArray: function() {
                return this.get();
            },
            size: function() {
                return this.length;
            },
            remove: function() {
                return this.each(function() {
                    if (this.parentNode != null) this.parentNode.removeChild(this);
                });
            },
            each: function(callback) {
                emptyArray.every.call(this, function(el, idx) {
                    return callback.call(el, idx, el) !== false;
                });
                return this;
            },
            filter: function(selector) {
                if (isFunction(selector)) return this.not(this.not(selector));
                return $(filter.call(this, function(element) {
                    return zepto.matches(element, selector);
                }));
            },
            add: function(selector, context) {
                return $(uniq(this.concat($(selector, context))));
            },
            is: function(selector) {
                return this.length > 0 && zepto.matches(this[0], selector);
            },
            not: function(selector) {
                var nodes = [];
                if (isFunction(selector) && selector.call !== undefined) this.each(function(idx) {
                    if (!selector.call(this, idx)) nodes.push(this);
                }); else {
                    var excludes = typeof selector == "string" ? this.filter(selector) : likeArray(selector) && isFunction(selector.item) ? slice.call(selector) : $(selector);
                    this.forEach(function(el) {
                        if (excludes.indexOf(el) < 0) nodes.push(el);
                    });
                }
                return $(nodes);
            },
            has: function(selector) {
                return this.filter(function() {
                    return isObject(selector) ? $.contains(this, selector) : $(this).find(selector).size();
                });
            },
            eq: function(idx) {
                return idx === -1 ? this.slice(idx) : this.slice(idx, +idx + 1);
            },
            first: function() {
                var el = this[0];
                return el && !isObject(el) ? el : $(el);
            },
            last: function() {
                var el = this[this.length - 1];
                return el && !isObject(el) ? el : $(el);
            },
            find: function(selector) {
                var result, $this = this;
                if (!selector) result = $(); else if (typeof selector == "object") result = $(selector).filter(function() {
                    var node = this;
                    return emptyArray.some.call($this, function(parent) {
                        return $.contains(parent, node);
                    });
                }); else if (this.length == 1) result = $(zepto.qsa(this[0], selector)); else result = this.map(function() {
                    return zepto.qsa(this, selector);
                });
                return result;
            },
            closest: function(selector, context) {
                var nodes = [], collection = typeof selector == "object" && $(selector);
                this.each(function(_, node) {
                    while (node && !(collection ? collection.indexOf(node) >= 0 : zepto.matches(node, selector))) node = node !== context && !isDocument(node) && node.parentNode;
                    if (node && nodes.indexOf(node) < 0) nodes.push(node);
                });
                return $(nodes);
            },
            parents: function(selector) {
                var ancestors = [], nodes = this;
                while (nodes.length > 0) nodes = $.map(nodes, function(node) {
                    if ((node = node.parentNode) && !isDocument(node) && ancestors.indexOf(node) < 0) {
                        ancestors.push(node);
                        return node;
                    }
                });
                return filtered(ancestors, selector);
            },
            parent: function(selector) {
                return filtered(uniq(this.pluck("parentNode")), selector);
            },
            children: function(selector) {
                return filtered(this.map(function() {
                    return children(this);
                }), selector);
            },
            contents: function() {
                return this.map(function() {
                    return this.contentDocument || slice.call(this.childNodes);
                });
            },
            siblings: function(selector) {
                return filtered(this.map(function(i, el) {
                    return filter.call(children(el.parentNode), function(child) {
                        return child !== el;
                    });
                }), selector);
            },
            empty: function() {
                return this.each(function() {
                    this.innerHTML = "";
                });
            },
            pluck: function(property) {
                return $.map(this, function(el) {
                    return el[property];
                });
            },
            show: function() {
                return this.each(function() {
                    this.style.display == "none" && (this.style.display = "");
                    if (getComputedStyle(this, "").getPropertyValue("display") == "none") this.style.display = defaultDisplay(this.nodeName);
                });
            },
            replaceWith: function(newContent) {
                return this.before(newContent).remove();
            },
            wrap: function(structure) {
                var func = isFunction(structure);
                if (this[0] && !func) var dom = $(structure).get(0), clone = dom.parentNode || this.length > 1;
                return this.each(function(index) {
                    $(this).wrapAll(func ? structure.call(this, index) : clone ? dom.cloneNode(true) : dom);
                });
            },
            wrapAll: function(structure) {
                if (this[0]) {
                    $(this[0]).before(structure = $(structure));
                    var children;
                    while ((children = structure.children()).length) structure = children.first();
                    $(structure).append(this);
                }
                return this;
            },
            wrapInner: function(structure) {
                var func = isFunction(structure);
                return this.each(function(index) {
                    var self = $(this), contents = self.contents(), dom = func ? structure.call(this, index) : structure;
                    contents.length ? contents.wrapAll(dom) : self.append(dom);
                });
            },
            unwrap: function() {
                this.parent().each(function() {
                    $(this).replaceWith($(this).children());
                });
                return this;
            },
            clone: function() {
                return this.map(function() {
                    return this.cloneNode(true);
                });
            },
            hide: function() {
                return this.css("display", "none");
            },
            toggle: function(setting) {
                return this.each(function() {
                    var el = $(this);
                    (setting === undefined ? el.css("display") == "none" : setting) ? el.show() : el.hide();
                });
            },
            prev: function(selector) {
                return $(this.pluck("previousElementSibling")).filter(selector || "*");
            },
            next: function(selector) {
                return $(this.pluck("nextElementSibling")).filter(selector || "*");
            },
            html: function(html) {
                return 0 in arguments ? this.each(function(idx) {
                    var originHtml = this.innerHTML;
                    $(this).empty().append(funcArg(this, html, idx, originHtml));
                }) : 0 in this ? this[0].innerHTML : null;
            },
            text: function(text) {
                return 0 in arguments ? this.each(function(idx) {
                    var newText = funcArg(this, text, idx, this.textContent);
                    this.textContent = newText == null ? "" : "" + newText;
                }) : 0 in this ? this.pluck("textContent").join("") : null;
            },
            attr: function(name, value) {
                var result;
                return typeof name == "string" && !(1 in arguments) ? 0 in this && this[0].nodeType == 1 && (result = this[0].getAttribute(name)) != null ? result : undefined : this.each(function(idx) {
                    if (this.nodeType !== 1) return;
                    if (isObject(name)) for (key in name) setAttribute(this, key, name[key]); else setAttribute(this, name, funcArg(this, value, idx, this.getAttribute(name)));
                });
            },
            removeAttr: function(name) {
                return this.each(function() {
                    this.nodeType === 1 && name.split(" ").forEach(function(attribute) {
                        setAttribute(this, attribute);
                    }, this);
                });
            },
            prop: function(name, value) {
                name = propMap[name] || name;
                return 1 in arguments ? this.each(function(idx) {
                    this[name] = funcArg(this, value, idx, this[name]);
                }) : this[0] && this[0][name];
            },
            removeProp: function(name) {
                name = propMap[name] || name;
                return this.each(function() {
                    delete this[name];
                });
            },
            data: function(name, value) {
                var attrName = "data-" + name.replace(capitalRE, "-$1").toLowerCase();
                var data = 1 in arguments ? this.attr(attrName, value) : this.attr(attrName);
                return data !== null ? deserializeValue(data) : undefined;
            },
            val: function(value) {
                if (0 in arguments) {
                    if (value == null) value = "";
                    return this.each(function(idx) {
                        this.value = funcArg(this, value, idx, this.value);
                    });
                } else {
                    return this[0] && (this[0].multiple ? $(this[0]).find("option").filter(function() {
                        return this.selected;
                    }).pluck("value") : this[0].value);
                }
            },
            offset: function(coordinates) {
                if (coordinates) return this.each(function(index) {
                    var $this = $(this), coords = funcArg(this, coordinates, index, $this.offset()), parentOffset = $this.offsetParent().offset(), props = {
                        top: coords.top - parentOffset.top,
                        left: coords.left - parentOffset.left
                    };
                    if ($this.css("position") == "static") props["position"] = "relative";
                    $this.css(props);
                });
                if (!this.length) return null;
                if (document.documentElement !== this[0] && !$.contains(document.documentElement, this[0])) return {
                    top: 0,
                    left: 0
                };
                var obj = this[0].getBoundingClientRect();
                return {
                    left: obj.left + window.pageXOffset,
                    top: obj.top + window.pageYOffset,
                    width: Math.round(obj.width),
                    height: Math.round(obj.height)
                };
            },
            css: function(property, value) {
                if (arguments.length < 2) {
                    var element = this[0];
                    if (typeof property == "string") {
                        if (!element) return;
                        return element.style[camelize(property)] || getComputedStyle(element, "").getPropertyValue(property);
                    } else if (isArray(property)) {
                        if (!element) return;
                        var props = {};
                        var computedStyle = getComputedStyle(element, "");
                        $.each(property, function(_, prop) {
                            props[prop] = element.style[camelize(prop)] || computedStyle.getPropertyValue(prop);
                        });
                        return props;
                    }
                }
                var css = "";
                if (type(property) == "string") {
                    if (!value && value !== 0) this.each(function() {
                        this.style.removeProperty(dasherize(property));
                    }); else css = dasherize(property) + ":" + maybeAddPx(property, value);
                } else {
                    for (key in property) if (!property[key] && property[key] !== 0) this.each(function() {
                        this.style.removeProperty(dasherize(key));
                    }); else css += dasherize(key) + ":" + maybeAddPx(key, property[key]) + ";";
                }
                return this.each(function() {
                    this.style.cssText += ";" + css;
                });
            },
            index: function(element) {
                return element ? this.indexOf($(element)[0]) : this.parent().children().indexOf(this[0]);
            },
            hasClass: function(name) {
                if (!name) return false;
                return emptyArray.some.call(this, function(el) {
                    return this.test(className(el));
                }, classRE(name));
            },
            addClass: function(name) {
                if (!name) return this;
                return this.each(function(idx) {
                    if (!("className" in this)) return;
                    classList = [];
                    var cls = className(this), newName = funcArg(this, name, idx, cls);
                    newName.split(/\s+/g).forEach(function(klass) {
                        if (!$(this).hasClass(klass)) classList.push(klass);
                    }, this);
                    classList.length && className(this, cls + (cls ? " " : "") + classList.join(" "));
                });
            },
            removeClass: function(name) {
                return this.each(function(idx) {
                    if (!("className" in this)) return;
                    if (name === undefined) return className(this, "");
                    classList = className(this);
                    funcArg(this, name, idx, classList).split(/\s+/g).forEach(function(klass) {
                        classList = classList.replace(classRE(klass), " ");
                    });
                    className(this, classList.trim());
                });
            },
            toggleClass: function(name, when) {
                if (!name) return this;
                return this.each(function(idx) {
                    var $this = $(this), names = funcArg(this, name, idx, className(this));
                    names.split(/\s+/g).forEach(function(klass) {
                        (when === undefined ? !$this.hasClass(klass) : when) ? $this.addClass(klass) : $this.removeClass(klass);
                    });
                });
            },
            scrollTop: function(value) {
                if (!this.length) return;
                var hasScrollTop = "scrollTop" in this[0];
                if (value === undefined) return hasScrollTop ? this[0].scrollTop : this[0].pageYOffset;
                return this.each(hasScrollTop ? function() {
                    this.scrollTop = value;
                } : function() {
                    this.scrollTo(this.scrollX, value);
                });
            },
            scrollLeft: function(value) {
                if (!this.length) return;
                var hasScrollLeft = "scrollLeft" in this[0];
                if (value === undefined) return hasScrollLeft ? this[0].scrollLeft : this[0].pageXOffset;
                return this.each(hasScrollLeft ? function() {
                    this.scrollLeft = value;
                } : function() {
                    this.scrollTo(value, this.scrollY);
                });
            },
            position: function() {
                if (!this.length) return;
                var elem = this[0], offsetParent = this.offsetParent(), offset = this.offset(), parentOffset = rootNodeRE.test(offsetParent[0].nodeName) ? {
                    top: 0,
                    left: 0
                } : offsetParent.offset();
                offset.top -= parseFloat($(elem).css("margin-top")) || 0;
                offset.left -= parseFloat($(elem).css("margin-left")) || 0;
                parentOffset.top += parseFloat($(offsetParent[0]).css("border-top-width")) || 0;
                parentOffset.left += parseFloat($(offsetParent[0]).css("border-left-width")) || 0;
                return {
                    top: offset.top - parentOffset.top,
                    left: offset.left - parentOffset.left
                };
            },
            offsetParent: function() {
                return this.map(function() {
                    var parent = this.offsetParent || document.body;
                    while (parent && !rootNodeRE.test(parent.nodeName) && $(parent).css("position") == "static") parent = parent.offsetParent;
                    return parent;
                });
            }
        };
        $.fn.detach = $.fn.remove;
        [ "width", "height" ].forEach(function(dimension) {
            var dimensionProperty = dimension.replace(/./, function(m) {
                return m[0].toUpperCase();
            });
            $.fn[dimension] = function(value) {
                var offset, el = this[0];
                if (value === undefined) return isWindow(el) ? el["inner" + dimensionProperty] : isDocument(el) ? el.documentElement["scroll" + dimensionProperty] : (offset = this.offset()) && offset[dimension]; else return this.each(function(idx) {
                    el = $(this);
                    el.css(dimension, funcArg(this, value, idx, el[dimension]()));
                });
            };
        });
        function traverseNode(node, fun) {
            fun(node);
            for (var i = 0, len = node.childNodes.length; i < len; i++) traverseNode(node.childNodes[i], fun);
        }
        adjacencyOperators.forEach(function(operator, operatorIndex) {
            var inside = operatorIndex % 2;
            $.fn[operator] = function() {
                var argType, nodes = $.map(arguments, function(arg) {
                    var arr = [];
                    argType = type(arg);
                    if (argType == "array") {
                        arg.forEach(function(el) {
                            if (el.nodeType !== undefined) return arr.push(el); else if ($.zepto.isZ(el)) return arr = arr.concat(el.get());
                            arr = arr.concat(zepto.fragment(el));
                        });
                        return arr;
                    }
                    return argType == "object" || arg == null ? arg : zepto.fragment(arg);
                }), parent, copyByClone = this.length > 1;
                if (nodes.length < 1) return this;
                return this.each(function(_, target) {
                    parent = inside ? target : target.parentNode;
                    target = operatorIndex == 0 ? target.nextSibling : operatorIndex == 1 ? target.firstChild : operatorIndex == 2 ? target : null;
                    var parentInDocument = $.contains(document.documentElement, parent);
                    nodes.forEach(function(node) {
                        if (copyByClone) node = node.cloneNode(true); else if (!parent) return $(node).remove();
                        parent.insertBefore(node, target);
                        if (parentInDocument) traverseNode(node, function(el) {
                            if (el.nodeName != null && el.nodeName.toUpperCase() === "SCRIPT" && (!el.type || el.type === "text/javascript") && !el.src) {
                                var target = el.ownerDocument ? el.ownerDocument.defaultView : window;
                                target["eval"].call(target, el.innerHTML);
                            }
                        });
                    });
                });
            };
            $.fn[inside ? operator + "To" : "insert" + (operatorIndex ? "Before" : "After")] = function(html) {
                $(html)[operator](this);
                return this;
            };
        });
        zepto.Z.prototype = Z.prototype = $.fn;
        zepto.uniq = uniq;
        zepto.deserializeValue = deserializeValue;
        $.zepto = zepto;
        return $;
    }();
    window.Zepto = Zepto;
    window.$ === undefined && (window.$ = Zepto);
    (function($) {
        var _zid = 1, undefined, slice = Array.prototype.slice, isFunction = $.isFunction, isString = function(obj) {
            return typeof obj == "string";
        }, handlers = {}, specialEvents = {}, focusinSupported = "onfocusin" in window, focus = {
            focus: "focusin",
            blur: "focusout"
        }, hover = {
            mouseenter: "mouseover",
            mouseleave: "mouseout"
        };
        specialEvents.click = specialEvents.mousedown = specialEvents.mouseup = specialEvents.mousemove = "MouseEvents";
        function zid(element) {
            return element._zid || (element._zid = _zid++);
        }
        function findHandlers(element, event, fn, selector) {
            event = parse(event);
            if (event.ns) var matcher = matcherFor(event.ns);
            return (handlers[zid(element)] || []).filter(function(handler) {
                return handler && (!event.e || handler.e == event.e) && (!event.ns || matcher.test(handler.ns)) && (!fn || zid(handler.fn) === zid(fn)) && (!selector || handler.sel == selector);
            });
        }
        function parse(event) {
            var parts = ("" + event).split(".");
            return {
                e: parts[0],
                ns: parts.slice(1).sort().join(" ")
            };
        }
        function matcherFor(ns) {
            return new RegExp("(?:^| )" + ns.replace(" ", " .* ?") + "(?: |$)");
        }
        function eventCapture(handler, captureSetting) {
            return handler.del && (!focusinSupported && handler.e in focus) || !!captureSetting;
        }
        function realEvent(type) {
            return hover[type] || focusinSupported && focus[type] || type;
        }
        function add(element, events, fn, data, selector, delegator, capture) {
            var id = zid(element), set = handlers[id] || (handlers[id] = []);
            events.split(/\s/).forEach(function(event) {
                if (event == "ready") return $(document).ready(fn);
                var handler = parse(event);
                handler.fn = fn;
                handler.sel = selector;
                if (handler.e in hover) fn = function(e) {
                    var related = e.relatedTarget;
                    if (!related || related !== this && !$.contains(this, related)) return handler.fn.apply(this, arguments);
                };
                handler.del = delegator;
                var callback = delegator || fn;
                handler.proxy = function(e) {
                    e = compatible(e);
                    if (e.isImmediatePropagationStopped()) return;
                    e.data = data;
                    var result = callback.apply(element, e._args == undefined ? [ e ] : [ e ].concat(e._args));
                    if (result === false) e.preventDefault(), e.stopPropagation();
                    return result;
                };
                handler.i = set.length;
                set.push(handler);
                if ("addEventListener" in element) element.addEventListener(realEvent(handler.e), handler.proxy, eventCapture(handler, capture));
            });
        }
        function remove(element, events, fn, selector, capture) {
            var id = zid(element);
            (events || "").split(/\s/).forEach(function(event) {
                findHandlers(element, event, fn, selector).forEach(function(handler) {
                    delete handlers[id][handler.i];
                    if ("removeEventListener" in element) element.removeEventListener(realEvent(handler.e), handler.proxy, eventCapture(handler, capture));
                });
            });
        }
        $.event = {
            add: add,
            remove: remove
        };
        $.proxy = function(fn, context) {
            var args = 2 in arguments && slice.call(arguments, 2);
            if (isFunction(fn)) {
                var proxyFn = function() {
                    return fn.apply(context, args ? args.concat(slice.call(arguments)) : arguments);
                };
                proxyFn._zid = zid(fn);
                return proxyFn;
            } else if (isString(context)) {
                if (args) {
                    args.unshift(fn[context], fn);
                    return $.proxy.apply(null, args);
                } else {
                    return $.proxy(fn[context], fn);
                }
            } else {
                throw new TypeError("expected function");
            }
        };
        $.fn.bind = function(event, data, callback) {
            return this.on(event, data, callback);
        };
        $.fn.unbind = function(event, callback) {
            return this.off(event, callback);
        };
        $.fn.one = function(event, selector, data, callback) {
            return this.on(event, selector, data, callback, 1);
        };
        var returnTrue = function() {
            return true;
        }, returnFalse = function() {
            return false;
        }, ignoreProperties = /^([A-Z]|returnValue$|layer[XY]$|webkitMovement[XY]$)/, eventMethods = {
            preventDefault: "isDefaultPrevented",
            stopImmediatePropagation: "isImmediatePropagationStopped",
            stopPropagation: "isPropagationStopped"
        };
        function compatible(event, source) {
            if (source || !event.isDefaultPrevented) {
                source || (source = event);
                $.each(eventMethods, function(name, predicate) {
                    var sourceMethod = source[name];
                    event[name] = function() {
                        this[predicate] = returnTrue;
                        return sourceMethod && sourceMethod.apply(source, arguments);
                    };
                    event[predicate] = returnFalse;
                });
                event.timeStamp || (event.timeStamp = Date.now());
                if (source.defaultPrevented !== undefined ? source.defaultPrevented : "returnValue" in source ? source.returnValue === false : source.getPreventDefault && source.getPreventDefault()) event.isDefaultPrevented = returnTrue;
            }
            return event;
        }
        function createProxy(event) {
            var key, proxy = {
                originalEvent: event
            };
            for (key in event) if (!ignoreProperties.test(key) && event[key] !== undefined) proxy[key] = event[key];
            return compatible(proxy, event);
        }
        $.fn.delegate = function(selector, event, callback) {
            return this.on(event, selector, callback);
        };
        $.fn.undelegate = function(selector, event, callback) {
            return this.off(event, selector, callback);
        };
        $.fn.live = function(event, callback) {
            $(document.body).delegate(this.selector, event, callback);
            return this;
        };
        $.fn.die = function(event, callback) {
            $(document.body).undelegate(this.selector, event, callback);
            return this;
        };
        $.fn.on = function(event, selector, data, callback, one) {
            var autoRemove, delegator, $this = this;
            if (event && !isString(event)) {
                $.each(event, function(type, fn) {
                    $this.on(type, selector, data, fn, one);
                });
                return $this;
            }
            if (!isString(selector) && !isFunction(callback) && callback !== false) callback = data, 
            data = selector, selector = undefined;
            if (callback === undefined || data === false) callback = data, data = undefined;
            if (callback === false) callback = returnFalse;
            return $this.each(function(_, element) {
                if (one) autoRemove = function(e) {
                    remove(element, e.type, callback);
                    return callback.apply(this, arguments);
                };
                if (selector) delegator = function(e) {
                    var evt, match = $(e.target).closest(selector, element).get(0);
                    if (match && match !== element) {
                        evt = $.extend(createProxy(e), {
                            currentTarget: match,
                            liveFired: element
                        });
                        return (autoRemove || callback).apply(match, [ evt ].concat(slice.call(arguments, 1)));
                    }
                };
                add(element, event, callback, data, selector, delegator || autoRemove);
            });
        };
        $.fn.off = function(event, selector, callback) {
            var $this = this;
            if (event && !isString(event)) {
                $.each(event, function(type, fn) {
                    $this.off(type, selector, fn);
                });
                return $this;
            }
            if (!isString(selector) && !isFunction(callback) && callback !== false) callback = selector, 
            selector = undefined;
            if (callback === false) callback = returnFalse;
            return $this.each(function() {
                remove(this, event, callback, selector);
            });
        };
        $.fn.trigger = function(event, args) {
            event = isString(event) || $.isPlainObject(event) ? $.Event(event) : compatible(event);
            event._args = args;
            return this.each(function() {
                if (event.type in focus && typeof this[event.type] == "function") this[event.type](); else if ("dispatchEvent" in this) this.dispatchEvent(event); else $(this).triggerHandler(event, args);
            });
        };
        $.fn.triggerHandler = function(event, args) {
            var e, result;
            this.each(function(i, element) {
                e = createProxy(isString(event) ? $.Event(event) : event);
                e._args = args;
                e.target = element;
                $.each(findHandlers(element, event.type || event), function(i, handler) {
                    result = handler.proxy(e);
                    if (e.isImmediatePropagationStopped()) return false;
                });
            });
            return result;
        };
        ("focusin focusout focus blur load resize scroll unload click dblclick " + "mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave " + "change select keydown keypress keyup error").split(" ").forEach(function(event) {
            $.fn[event] = function(callback) {
                return 0 in arguments ? this.bind(event, callback) : this.trigger(event);
            };
        });
        $.Event = function(type, props) {
            if (!isString(type)) props = type, type = props.type;
            var event = document.createEvent(specialEvents[type] || "Events"), bubbles = true;
            if (props) for (var name in props) name == "bubbles" ? bubbles = !!props[name] : event[name] = props[name];
            event.initEvent(type, bubbles, true);
            return compatible(event);
        };
    })(Zepto);
    (function($) {
        var jsonpID = +new Date(), document = window.document, key, name, rscript = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, scriptTypeRE = /^(?:text|application)\/javascript/i, xmlTypeRE = /^(?:text|application)\/xml/i, jsonType = "application/json", htmlType = "text/html", blankRE = /^\s*$/, originAnchor = document.createElement("a");
        originAnchor.href = window.location.href;
        function triggerAndReturn(context, eventName, data) {
            var event = $.Event(eventName);
            $(context).trigger(event, data);
            return !event.isDefaultPrevented();
        }
        function triggerGlobal(settings, context, eventName, data) {
            if (settings.global) return triggerAndReturn(context || document, eventName, data);
        }
        $.active = 0;
        function ajaxStart(settings) {
            if (settings.global && $.active++ === 0) triggerGlobal(settings, null, "ajaxStart");
        }
        function ajaxStop(settings) {
            if (settings.global && !--$.active) triggerGlobal(settings, null, "ajaxStop");
        }
        function ajaxBeforeSend(xhr, settings) {
            var context = settings.context;
            if (settings.beforeSend.call(context, xhr, settings) === false || triggerGlobal(settings, context, "ajaxBeforeSend", [ xhr, settings ]) === false) return false;
            triggerGlobal(settings, context, "ajaxSend", [ xhr, settings ]);
        }
        function ajaxSuccess(data, xhr, settings, deferred) {
            var context = settings.context, status = "success";
            settings.success.call(context, data, status, xhr);
            if (deferred) deferred.resolveWith(context, [ data, status, xhr ]);
            triggerGlobal(settings, context, "ajaxSuccess", [ xhr, settings, data ]);
            ajaxComplete(status, xhr, settings);
        }
        function ajaxError(error, type, xhr, settings, deferred) {
            var context = settings.context;
            settings.error.call(context, xhr, type, error);
            if (deferred) deferred.rejectWith(context, [ xhr, type, error ]);
            triggerGlobal(settings, context, "ajaxError", [ xhr, settings, error || type ]);
            ajaxComplete(type, xhr, settings);
        }
        function ajaxComplete(status, xhr, settings) {
            var context = settings.context;
            settings.complete.call(context, xhr, status);
            triggerGlobal(settings, context, "ajaxComplete", [ xhr, settings ]);
            ajaxStop(settings);
        }
        function ajaxDataFilter(data, type, settings) {
            if (settings.dataFilter == empty) return data;
            var context = settings.context;
            return settings.dataFilter.call(context, data, type);
        }
        function empty() {}
        $.ajaxJSONP = function(options, deferred) {
            if (!("type" in options)) return $.ajax(options);
            var _callbackName = options.jsonpCallback, callbackName = ($.isFunction(_callbackName) ? _callbackName() : _callbackName) || "Zepto" + jsonpID++, script = document.createElement("script"), originalCallback = window[callbackName], responseData, abort = function(errorType) {
                $(script).triggerHandler("error", errorType || "abort");
            }, xhr = {
                abort: abort
            }, abortTimeout;
            if (deferred) deferred.promise(xhr);
            $(script).on("load error", function(e, errorType) {
                clearTimeout(abortTimeout);
                $(script).off().remove();
                if (e.type == "error" || !responseData) {
                    ajaxError(null, errorType || "error", xhr, options, deferred);
                } else {
                    ajaxSuccess(responseData[0], xhr, options, deferred);
                }
                window[callbackName] = originalCallback;
                if (responseData && $.isFunction(originalCallback)) originalCallback(responseData[0]);
                originalCallback = responseData = undefined;
            });
            if (ajaxBeforeSend(xhr, options) === false) {
                abort("abort");
                return xhr;
            }
            window[callbackName] = function() {
                responseData = arguments;
            };
            script.src = options.url.replace(/\?(.+)=\?/, "?$1=" + callbackName);
            document.head.appendChild(script);
            if (options.timeout > 0) abortTimeout = setTimeout(function() {
                abort("timeout");
            }, options.timeout);
            return xhr;
        };
        $.ajaxSettings = {
            type: "GET",
            beforeSend: empty,
            success: empty,
            error: empty,
            complete: empty,
            context: null,
            global: true,
            xhr: function() {
                return new window.XMLHttpRequest();
            },
            accepts: {
                script: "text/javascript, application/javascript, application/x-javascript",
                json: jsonType,
                xml: "application/xml, text/xml",
                html: htmlType,
                text: "text/plain"
            },
            crossDomain: false,
            timeout: 0,
            processData: true,
            cache: true,
            dataFilter: empty
        };
        function mimeToDataType(mime) {
            if (mime) mime = mime.split(";", 2)[0];
            return mime && (mime == htmlType ? "html" : mime == jsonType ? "json" : scriptTypeRE.test(mime) ? "script" : xmlTypeRE.test(mime) && "xml") || "text";
        }
        function appendQuery(url, query) {
            if (query == "") return url;
            return (url + "&" + query).replace(/[&?]{1,2}/, "?");
        }
        function serializeData(options) {
            if (options.processData && options.data && $.type(options.data) != "string") options.data = $.param(options.data, options.traditional);
            if (options.data && (!options.type || options.type.toUpperCase() == "GET" || "jsonp" == options.dataType)) options.url = appendQuery(options.url, options.data), 
            options.data = undefined;
        }
        $.ajax = function(options) {
            var settings = $.extend({}, options || {}), deferred = $.Deferred && $.Deferred(), urlAnchor, hashIndex;
            for (key in $.ajaxSettings) if (settings[key] === undefined) settings[key] = $.ajaxSettings[key];
            ajaxStart(settings);
            if (!settings.crossDomain) {
                urlAnchor = document.createElement("a");
                urlAnchor.href = settings.url;
                urlAnchor.href = urlAnchor.href;
                settings.crossDomain = originAnchor.protocol + "//" + originAnchor.host !== urlAnchor.protocol + "//" + urlAnchor.host;
            }
            if (!settings.url) settings.url = window.location.toString();
            if ((hashIndex = settings.url.indexOf("#")) > -1) settings.url = settings.url.slice(0, hashIndex);
            serializeData(settings);
            var dataType = settings.dataType, hasPlaceholder = /\?.+=\?/.test(settings.url);
            if (hasPlaceholder) dataType = "jsonp";
            if (settings.cache === false || (!options || options.cache !== true) && ("script" == dataType || "jsonp" == dataType)) settings.url = appendQuery(settings.url, "_=" + Date.now());
            if ("jsonp" == dataType) {
                if (!hasPlaceholder) settings.url = appendQuery(settings.url, settings.jsonp ? settings.jsonp + "=?" : settings.jsonp === false ? "" : "callback=?");
                return $.ajaxJSONP(settings, deferred);
            }
            var mime = settings.accepts[dataType], headers = {}, setHeader = function(name, value) {
                headers[name.toLowerCase()] = [ name, value ];
            }, protocol = /^([\w-]+:)\/\//.test(settings.url) ? RegExp.$1 : window.location.protocol, xhr = settings.xhr(), nativeSetHeader = xhr.setRequestHeader, abortTimeout;
            if (deferred) deferred.promise(xhr);
            if (!settings.crossDomain) setHeader("X-Requested-With", "XMLHttpRequest");
            setHeader("Accept", mime || "*/*");
            if (mime = settings.mimeType || mime) {
                if (mime.indexOf(",") > -1) mime = mime.split(",", 2)[0];
                xhr.overrideMimeType && xhr.overrideMimeType(mime);
            }
            if (settings.contentType || settings.contentType !== false && settings.data && settings.type.toUpperCase() != "GET") setHeader("Content-Type", settings.contentType || "application/x-www-form-urlencoded");
            if (settings.headers) for (name in settings.headers) setHeader(name, settings.headers[name]);
            xhr.setRequestHeader = setHeader;
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4) {
                    xhr.onreadystatechange = empty;
                    clearTimeout(abortTimeout);
                    var result, error = false;
                    if (xhr.status >= 200 && xhr.status < 300 || xhr.status == 304 || xhr.status == 0 && protocol == "file:") {
                        dataType = dataType || mimeToDataType(settings.mimeType || xhr.getResponseHeader("content-type"));
                        if (xhr.responseType == "arraybuffer" || xhr.responseType == "blob") result = xhr.response; else {
                            result = xhr.responseText;
                            try {
                                result = ajaxDataFilter(result, dataType, settings);
                                if (dataType == "script") (1, eval)(result); else if (dataType == "xml") result = xhr.responseXML; else if (dataType == "json") result = blankRE.test(result) ? null : $.parseJSON(result);
                            } catch (e) {
                                error = e;
                            }
                            if (error) return ajaxError(error, "parsererror", xhr, settings, deferred);
                        }
                        ajaxSuccess(result, xhr, settings, deferred);
                    } else {
                        ajaxError(xhr.statusText || null, xhr.status ? "error" : "abort", xhr, settings, deferred);
                    }
                }
            };
            if (ajaxBeforeSend(xhr, settings) === false) {
                xhr.abort();
                ajaxError(null, "abort", xhr, settings, deferred);
                return xhr;
            }
            var async = "async" in settings ? settings.async : true;
            xhr.open(settings.type, settings.url, async, settings.username, settings.password);
            if (settings.xhrFields) for (name in settings.xhrFields) xhr[name] = settings.xhrFields[name];
            for (name in headers) nativeSetHeader.apply(xhr, headers[name]);
            if (settings.timeout > 0) abortTimeout = setTimeout(function() {
                xhr.onreadystatechange = empty;
                xhr.abort();
                ajaxError(null, "timeout", xhr, settings, deferred);
            }, settings.timeout);
            xhr.send(settings.data ? settings.data : null);
            return xhr;
        };
        function parseArguments(url, data, success, dataType) {
            if ($.isFunction(data)) dataType = success, success = data, data = undefined;
            if (!$.isFunction(success)) dataType = success, success = undefined;
            return {
                url: url,
                data: data,
                success: success,
                dataType: dataType
            };
        }
        $.get = function() {
            return $.ajax(parseArguments.apply(null, arguments));
        };
        $.post = function() {
            var options = parseArguments.apply(null, arguments);
            options.type = "POST";
            return $.ajax(options);
        };
        $.getJSON = function() {
            var options = parseArguments.apply(null, arguments);
            options.dataType = "json";
            return $.ajax(options);
        };
        $.fn.load = function(url, data, success) {
            if (!this.length) return this;
            var self = this, parts = url.split(/\s/), selector, options = parseArguments(url, data, success), callback = options.success;
            if (parts.length > 1) options.url = parts[0], selector = parts[1];
            options.success = function(response) {
                self.html(selector ? $("<div>").html(response.replace(rscript, "")).find(selector) : response);
                callback && callback.apply(self, arguments);
            };
            $.ajax(options);
            return this;
        };
        var escape = encodeURIComponent;
        function serialize(params, obj, traditional, scope) {
            var type, array = $.isArray(obj), hash = $.isPlainObject(obj);
            $.each(obj, function(key, value) {
                type = $.type(value);
                if (scope) key = traditional ? scope : scope + "[" + (hash || type == "object" || type == "array" ? key : "") + "]";
                if (!scope && array) params.add(value.name, value.value); else if (type == "array" || !traditional && type == "object") serialize(params, value, traditional, key); else params.add(key, value);
            });
        }
        $.param = function(obj, traditional) {
            var params = [];
            params.add = function(key, value) {
                if ($.isFunction(value)) value = value();
                if (value == null) value = "";
                this.push(escape(key) + "=" + escape(value));
            };
            serialize(params, obj, traditional);
            return params.join("&").replace(/%20/g, "+");
        };
    })(Zepto);
    (function($) {
        $.fn.serializeArray = function() {
            var name, type, result = [], add = function(value) {
                if (value.forEach) return value.forEach(add);
                result.push({
                    name: name,
                    value: value
                });
            };
            if (this[0]) $.each(this[0].elements, function(_, field) {
                type = field.type, name = field.name;
                if (name && field.nodeName.toLowerCase() != "fieldset" && !field.disabled && type != "submit" && type != "reset" && type != "button" && type != "file" && (type != "radio" && type != "checkbox" || field.checked)) add($(field).val());
            });
            return result;
        };
        $.fn.serialize = function() {
            var result = [];
            this.serializeArray().forEach(function(elm) {
                result.push(encodeURIComponent(elm.name) + "=" + encodeURIComponent(elm.value));
            });
            return result.join("&");
        };
        $.fn.submit = function(callback) {
            if (0 in arguments) this.bind("submit", callback); else if (this.length) {
                var event = $.Event("submit");
                this.eq(0).trigger(event);
                if (!event.isDefaultPrevented()) this.get(0).submit();
            }
            return this;
        };
    })(Zepto);
    (function() {
        try {
            getComputedStyle(undefined);
        } catch (e) {
            var nativeGetComputedStyle = getComputedStyle;
            window.getComputedStyle = function(element, pseudoElement) {
                try {
                    return nativeGetComputedStyle(element, pseudoElement);
                } catch (e) {
                    return null;
                }
            };
        }
    })();
    return Zepto;
});

(function($) {
    $.Callbacks = function(options) {
        options = $.extend({}, options);
        var memory, fired, firing, firingStart, firingLength, firingIndex, list = [], stack = !options.once && [], fire = function(data) {
            memory = options.memory && data;
            fired = true;
            firingIndex = firingStart || 0;
            firingStart = 0;
            firingLength = list.length;
            firing = true;
            for (;list && firingIndex < firingLength; ++firingIndex) {
                if (list[firingIndex].apply(data[0], data[1]) === false && options.stopOnFalse) {
                    memory = false;
                    break;
                }
            }
            firing = false;
            if (list) {
                if (stack) stack.length && fire(stack.shift()); else if (memory) list.length = 0; else Callbacks.disable();
            }
        }, Callbacks = {
            add: function() {
                if (list) {
                    var start = list.length, add = function(args) {
                        $.each(args, function(_, arg) {
                            if (typeof arg === "function") {
                                if (!options.unique || !Callbacks.has(arg)) list.push(arg);
                            } else if (arg && arg.length && typeof arg !== "string") add(arg);
                        });
                    };
                    add(arguments);
                    if (firing) firingLength = list.length; else if (memory) {
                        firingStart = start;
                        fire(memory);
                    }
                }
                return this;
            },
            remove: function() {
                if (list) {
                    $.each(arguments, function(_, arg) {
                        var index;
                        while ((index = $.inArray(arg, list, index)) > -1) {
                            list.splice(index, 1);
                            if (firing) {
                                if (index <= firingLength) --firingLength;
                                if (index <= firingIndex) --firingIndex;
                            }
                        }
                    });
                }
                return this;
            },
            has: function(fn) {
                return !!(list && (fn ? $.inArray(fn, list) > -1 : list.length));
            },
            empty: function() {
                firingLength = list.length = 0;
                return this;
            },
            disable: function() {
                list = stack = memory = undefined;
                return this;
            },
            disabled: function() {
                return !list;
            },
            lock: function() {
                stack = undefined;
                if (!memory) Callbacks.disable();
                return this;
            },
            locked: function() {
                return !stack;
            },
            fireWith: function(context, args) {
                if (list && (!fired || stack)) {
                    args = args || [];
                    args = [ context, args.slice ? args.slice() : args ];
                    if (firing) stack.push(args); else fire(args);
                }
                return this;
            },
            fire: function() {
                return Callbacks.fireWith(this, arguments);
            },
            fired: function() {
                return !!fired;
            }
        };
        return Callbacks;
    };
})(Zepto);

(function($) {
    var slice = Array.prototype.slice;
    function Deferred(func) {
        var tuples = [ [ "resolve", "done", $.Callbacks({
            once: 1,
            memory: 1
        }), "resolved" ], [ "reject", "fail", $.Callbacks({
            once: 1,
            memory: 1
        }), "rejected" ], [ "notify", "progress", $.Callbacks({
            memory: 1
        }) ] ], state = "pending", promise = {
            state: function() {
                return state;
            },
            always: function() {
                deferred.done(arguments).fail(arguments);
                return this;
            },
            then: function() {
                var fns = arguments;
                return Deferred(function(defer) {
                    $.each(tuples, function(i, tuple) {
                        var fn = $.isFunction(fns[i]) && fns[i];
                        deferred[tuple[1]](function() {
                            var returned = fn && fn.apply(this, arguments);
                            if (returned && $.isFunction(returned.promise)) {
                                returned.promise().done(defer.resolve).fail(defer.reject).progress(defer.notify);
                            } else {
                                var context = this === promise ? defer.promise() : this, values = fn ? [ returned ] : arguments;
                                defer[tuple[0] + "With"](context, values);
                            }
                        });
                    });
                    fns = null;
                }).promise();
            },
            promise: function(obj) {
                return obj != null ? $.extend(obj, promise) : promise;
            }
        }, deferred = {};
        $.each(tuples, function(i, tuple) {
            var list = tuple[2], stateString = tuple[3];
            promise[tuple[1]] = list.add;
            if (stateString) {
                list.add(function() {
                    state = stateString;
                }, tuples[i ^ 1][2].disable, tuples[2][2].lock);
            }
            deferred[tuple[0]] = function() {
                deferred[tuple[0] + "With"](this === deferred ? promise : this, arguments);
                return this;
            };
            deferred[tuple[0] + "With"] = list.fireWith;
        });
        promise.promise(deferred);
        if (func) func.call(deferred, deferred);
        return deferred;
    }
    $.when = function(sub) {
        var resolveValues = slice.call(arguments), len = resolveValues.length, i = 0, remain = len !== 1 || sub && $.isFunction(sub.promise) ? len : 0, deferred = remain === 1 ? sub : Deferred(), progressValues, progressContexts, resolveContexts, updateFn = function(i, ctx, val) {
            return function(value) {
                ctx[i] = this;
                val[i] = arguments.length > 1 ? slice.call(arguments) : value;
                if (val === progressValues) {
                    deferred.notifyWith(ctx, val);
                } else if (!--remain) {
                    deferred.resolveWith(ctx, val);
                }
            };
        };
        if (len > 1) {
            progressValues = new Array(len);
            progressContexts = new Array(len);
            resolveContexts = new Array(len);
            for (;i < len; ++i) {
                if (resolveValues[i] && $.isFunction(resolveValues[i].promise)) {
                    resolveValues[i].promise().done(updateFn(i, resolveContexts, resolveValues)).fail(deferred.reject).progress(updateFn(i, progressContexts, progressValues));
                } else {
                    --remain;
                }
            }
        }
        if (!remain) deferred.resolveWith(resolveContexts, resolveValues);
        return deferred.promise();
    };
    $.Deferred = Deferred;
})(Zepto);

(function(global, factory) {
    typeof exports === "object" && typeof module !== "undefined" ? factory(exports) : typeof define === "function" && define.amd ? define([ "exports" ], factory) : factory(global.riot = global.riot || {});
})(this, function(exports) {
    "use strict";
    var __TAGS_CACHE = [];
    var __TAG_IMPL = {};
    var GLOBAL_MIXIN = "__global_mixin";
    var ATTRS_PREFIX = "riot-";
    var REF_DIRECTIVES = [ "ref", "data-ref" ];
    var IS_DIRECTIVE = "data-is";
    var CONDITIONAL_DIRECTIVE = "if";
    var LOOP_DIRECTIVE = "each";
    var LOOP_NO_REORDER_DIRECTIVE = "no-reorder";
    var SHOW_DIRECTIVE = "show";
    var HIDE_DIRECTIVE = "hide";
    var T_STRING = "string";
    var T_OBJECT = "object";
    var T_UNDEF = "undefined";
    var T_FUNCTION = "function";
    var XLINK_NS = "http://www.w3.org/1999/xlink";
    var XLINK_REGEX = /^xlink:(\w+)/;
    var WIN = typeof window === T_UNDEF ? undefined : window;
    var RE_SPECIAL_TAGS = /^(?:t(?:body|head|foot|[rhd])|caption|col(?:group)?|opt(?:ion|group))$/;
    var RE_SPECIAL_TAGS_NO_OPTION = /^(?:t(?:body|head|foot|[rhd])|caption|col(?:group)?)$/;
    var RE_RESERVED_NAMES = /^(?:_(?:item|id|parent)|update|root|(?:un)?mount|mixin|is(?:Mounted|Loop)|tags|refs|parent|opts|trigger|o(?:n|ff|ne))$/;
    var RE_HTML_ATTRS = /([-\w]+) ?= ?(?:"([^"]*)|'([^']*)|({[^}]*}))/g;
    var CASE_SENSITIVE_ATTRIBUTES = {
        viewbox: "viewBox"
    };
    var RE_BOOL_ATTRS = /^(?:disabled|checked|readonly|required|allowfullscreen|auto(?:focus|play)|compact|controls|default|formnovalidate|hidden|ismap|itemscope|loop|multiple|muted|no(?:resize|shade|validate|wrap)?|open|reversed|seamless|selected|sortable|truespeed|typemustmatch)$/;
    var IE_VERSION = (WIN && WIN.document || {}).documentMode | 0;
    function isBoolAttr(value) {
        return RE_BOOL_ATTRS.test(value);
    }
    function isFunction(value) {
        return typeof value === T_FUNCTION;
    }
    function isObject(value) {
        return value && typeof value === T_OBJECT;
    }
    function isUndefined(value) {
        return typeof value === T_UNDEF;
    }
    function isString(value) {
        return typeof value === T_STRING;
    }
    function isBlank(value) {
        return isUndefined(value) || value === null || value === "";
    }
    function isArray(value) {
        return Array.isArray(value) || value instanceof Array;
    }
    function isWritable(obj, key) {
        var descriptor = Object.getOwnPropertyDescriptor(obj, key);
        return isUndefined(obj[key]) || descriptor && descriptor.writable;
    }
    function isReservedName(value) {
        return RE_RESERVED_NAMES.test(value);
    }
    var check = Object.freeze({
        isBoolAttr: isBoolAttr,
        isFunction: isFunction,
        isObject: isObject,
        isUndefined: isUndefined,
        isString: isString,
        isBlank: isBlank,
        isArray: isArray,
        isWritable: isWritable,
        isReservedName: isReservedName
    });
    function $$(selector, ctx) {
        return (ctx || document).querySelectorAll(selector);
    }
    function $(selector, ctx) {
        return (ctx || document).querySelector(selector);
    }
    function createFrag() {
        return document.createDocumentFragment();
    }
    function createDOMPlaceholder() {
        return document.createTextNode("");
    }
    function mkEl(name) {
        return document.createElement(name);
    }
    function setInnerHTML(container, html) {
        if (!isUndefined(container.innerHTML)) {
            container.innerHTML = html;
        } else {
            var doc = new DOMParser().parseFromString(html, "application/xml");
            var node = container.ownerDocument.importNode(doc.documentElement, true);
            container.appendChild(node);
        }
    }
    function remAttr(dom, name) {
        dom.removeAttribute(name);
    }
    function getAttr(dom, name) {
        return dom.getAttribute(name);
    }
    function setAttr(dom, name, val) {
        var xlink = XLINK_REGEX.exec(name);
        if (xlink && xlink[1]) {
            dom.setAttributeNS(XLINK_NS, xlink[1], val);
        } else {
            dom.setAttribute(name, val);
        }
    }
    function safeInsert(root, curr, next) {
        root.insertBefore(curr, next.parentNode && next);
    }
    function walkAttrs(html, fn) {
        if (!html) {
            return;
        }
        var m;
        while (m = RE_HTML_ATTRS.exec(html)) {
            fn(m[1].toLowerCase(), m[2] || m[3] || m[4]);
        }
    }
    function walkNodes(dom, fn, context) {
        if (dom) {
            var res = fn(dom, context);
            var next;
            if (res === false) {
                return;
            }
            dom = dom.firstChild;
            while (dom) {
                next = dom.nextSibling;
                walkNodes(dom, fn, res);
                dom = next;
            }
        }
    }
    var dom = Object.freeze({
        $$: $$,
        $: $,
        createFrag: createFrag,
        createDOMPlaceholder: createDOMPlaceholder,
        mkEl: mkEl,
        setInnerHTML: setInnerHTML,
        remAttr: remAttr,
        getAttr: getAttr,
        setAttr: setAttr,
        safeInsert: safeInsert,
        walkAttrs: walkAttrs,
        walkNodes: walkNodes
    });
    var styleNode;
    var cssTextProp;
    var byName = {};
    var remainder = [];
    var needsInject = false;
    if (WIN) {
        styleNode = function() {
            var newNode = mkEl("style");
            setAttr(newNode, "type", "text/css");
            var userNode = $("style[type=riot]");
            if (userNode) {
                if (userNode.id) {
                    newNode.id = userNode.id;
                }
                userNode.parentNode.replaceChild(newNode, userNode);
            } else {
                document.getElementsByTagName("head")[0].appendChild(newNode);
            }
            return newNode;
        }();
        cssTextProp = styleNode.styleSheet;
    }
    var styleManager = {
        styleNode: styleNode,
        add: function add(css, name) {
            if (name) {
                byName[name] = css;
            } else {
                remainder.push(css);
            }
            needsInject = true;
        },
        inject: function inject() {
            if (!WIN || !needsInject) {
                return;
            }
            needsInject = false;
            var style = Object.keys(byName).map(function(k) {
                return byName[k];
            }).concat(remainder).join("\n");
            if (cssTextProp) {
                cssTextProp.cssText = style;
            } else {
                styleNode.innerHTML = style;
            }
        }
    };
    var brackets = function(UNDEF) {
        var REGLOB = "g", R_MLCOMMS = /\/\*[^*]*\*+(?:[^*\/][^*]*\*+)*\//g, R_STRINGS = /"[^"\\]*(?:\\[\S\s][^"\\]*)*"|'[^'\\]*(?:\\[\S\s][^'\\]*)*'|`[^`\\]*(?:\\[\S\s][^`\\]*)*`/g, S_QBLOCKS = R_STRINGS.source + "|" + /(?:\breturn\s+|(?:[$\w\)\]]|\+\+|--)\s*(\/)(?![*\/]))/.source + "|" + /\/(?=[^*\/])[^[\/\\]*(?:(?:\[(?:\\.|[^\]\\]*)*\]|\\.)[^[\/\\]*)*?(\/)[gim]*/.source, UNSUPPORTED = RegExp("[\\" + "x00-\\x1F<>a-zA-Z0-9'\",;\\\\]"), NEED_ESCAPE = /(?=[[\]()*+?.^$|])/g, FINDBRACES = {
            "(": RegExp("([()])|" + S_QBLOCKS, REGLOB),
            "[": RegExp("([[\\]])|" + S_QBLOCKS, REGLOB),
            "{": RegExp("([{}])|" + S_QBLOCKS, REGLOB)
        }, DEFAULT = "{ }";
        var _pairs = [ "{", "}", "{", "}", /{[^}]*}/, /\\([{}])/g, /\\({)|{/g, RegExp("\\\\(})|([[({])|(})|" + S_QBLOCKS, REGLOB), DEFAULT, /^\s*{\^?\s*([$\w]+)(?:\s*,\s*(\S+))?\s+in\s+(\S.*)\s*}/, /(^|[^\\]){=[\S\s]*?}/ ];
        var cachedBrackets = UNDEF, _regex, _cache = [], _settings;
        function _loopback(re) {
            return re;
        }
        function _rewrite(re, bp) {
            if (!bp) {
                bp = _cache;
            }
            return new RegExp(re.source.replace(/{/g, bp[2]).replace(/}/g, bp[3]), re.global ? REGLOB : "");
        }
        function _create(pair) {
            if (pair === DEFAULT) {
                return _pairs;
            }
            var arr = pair.split(" ");
            if (arr.length !== 2 || UNSUPPORTED.test(pair)) {
                throw new Error('Unsupported brackets "' + pair + '"');
            }
            arr = arr.concat(pair.replace(NEED_ESCAPE, "\\").split(" "));
            arr[4] = _rewrite(arr[1].length > 1 ? /{[\S\s]*?}/ : _pairs[4], arr);
            arr[5] = _rewrite(pair.length > 3 ? /\\({|})/g : _pairs[5], arr);
            arr[6] = _rewrite(_pairs[6], arr);
            arr[7] = RegExp("\\\\(" + arr[3] + ")|([[({])|(" + arr[3] + ")|" + S_QBLOCKS, REGLOB);
            arr[8] = pair;
            return arr;
        }
        function _brackets(reOrIdx) {
            return reOrIdx instanceof RegExp ? _regex(reOrIdx) : _cache[reOrIdx];
        }
        _brackets.split = function split(str, tmpl, _bp) {
            if (!_bp) {
                _bp = _cache;
            }
            var parts = [], match, isexpr, start, pos, re = _bp[6];
            isexpr = start = re.lastIndex = 0;
            while (match = re.exec(str)) {
                pos = match.index;
                if (isexpr) {
                    if (match[2]) {
                        re.lastIndex = skipBraces(str, match[2], re.lastIndex);
                        continue;
                    }
                    if (!match[3]) {
                        continue;
                    }
                }
                if (!match[1]) {
                    unescapeStr(str.slice(start, pos));
                    start = re.lastIndex;
                    re = _bp[6 + (isexpr ^= 1)];
                    re.lastIndex = start;
                }
            }
            if (str && start < str.length) {
                unescapeStr(str.slice(start));
            }
            return parts;
            function unescapeStr(s) {
                if (tmpl || isexpr) {
                    parts.push(s && s.replace(_bp[5], "$1"));
                } else {
                    parts.push(s);
                }
            }
            function skipBraces(s, ch, ix) {
                var match, recch = FINDBRACES[ch];
                recch.lastIndex = ix;
                ix = 1;
                while (match = recch.exec(s)) {
                    if (match[1] && !(match[1] === ch ? ++ix : --ix)) {
                        break;
                    }
                }
                return ix ? s.length : recch.lastIndex;
            }
        };
        _brackets.hasExpr = function hasExpr(str) {
            return _cache[4].test(str);
        };
        _brackets.loopKeys = function loopKeys(expr) {
            var m = expr.match(_cache[9]);
            return m ? {
                key: m[1],
                pos: m[2],
                val: _cache[0] + m[3].trim() + _cache[1]
            } : {
                val: expr.trim()
            };
        };
        _brackets.array = function array(pair) {
            return pair ? _create(pair) : _cache;
        };
        function _reset(pair) {
            if ((pair || (pair = DEFAULT)) !== _cache[8]) {
                _cache = _create(pair);
                _regex = pair === DEFAULT ? _loopback : _rewrite;
                _cache[9] = _regex(_pairs[9]);
            }
            cachedBrackets = pair;
        }
        function _setSettings(o) {
            var b;
            o = o || {};
            b = o.brackets;
            Object.defineProperty(o, "brackets", {
                set: _reset,
                get: function() {
                    return cachedBrackets;
                },
                enumerable: true
            });
            _settings = o;
            _reset(b);
        }
        Object.defineProperty(_brackets, "settings", {
            set: _setSettings,
            get: function() {
                return _settings;
            }
        });
        _brackets.settings = typeof riot !== "undefined" && riot.settings || {};
        _brackets.set = _reset;
        _brackets.R_STRINGS = R_STRINGS;
        _brackets.R_MLCOMMS = R_MLCOMMS;
        _brackets.S_QBLOCKS = S_QBLOCKS;
        return _brackets;
    }();
    var tmpl = function() {
        var _cache = {};
        function _tmpl(str, data) {
            if (!str) {
                return str;
            }
            return (_cache[str] || (_cache[str] = _create(str))).call(data, _logErr);
        }
        _tmpl.hasExpr = brackets.hasExpr;
        _tmpl.loopKeys = brackets.loopKeys;
        _tmpl.clearCache = function() {
            _cache = {};
        };
        _tmpl.errorHandler = null;
        function _logErr(err, ctx) {
            err.riotData = {
                tagName: ctx && ctx.__ && ctx.__.tagName,
                _riot_id: ctx && ctx._riot_id
            };
            if (_tmpl.errorHandler) {
                _tmpl.errorHandler(err);
            } else if (typeof console !== "undefined" && typeof console.error === "function") {
                if (err.riotData.tagName) {
                    console.error("Riot template error thrown in the <%s> tag", err.riotData.tagName);
                }
                console.error(err);
            }
        }
        function _create(str) {
            var expr = _getTmpl(str);
            if (expr.slice(0, 11) !== "try{return ") {
                expr = "return " + expr;
            }
            return new Function("E", expr + ";");
        }
        var CH_IDEXPR = String.fromCharCode(8279), RE_CSNAME = /^(?:(-?[_A-Za-z\xA0-\xFF][-\w\xA0-\xFF]*)|\u2057(\d+)~):/, RE_QBLOCK = RegExp(brackets.S_QBLOCKS, "g"), RE_DQUOTE = /\u2057/g, RE_QBMARK = /\u2057(\d+)~/g;
        function _getTmpl(str) {
            var qstr = [], expr, parts = brackets.split(str.replace(RE_DQUOTE, '"'), 1);
            if (parts.length > 2 || parts[0]) {
                var i, j, list = [];
                for (i = j = 0; i < parts.length; ++i) {
                    expr = parts[i];
                    if (expr && (expr = i & 1 ? _parseExpr(expr, 1, qstr) : '"' + expr.replace(/\\/g, "\\\\").replace(/\r\n?|\n/g, "\\n").replace(/"/g, '\\"') + '"')) {
                        list[j++] = expr;
                    }
                }
                expr = j < 2 ? list[0] : "[" + list.join(",") + '].join("")';
            } else {
                expr = _parseExpr(parts[1], 0, qstr);
            }
            if (qstr[0]) {
                expr = expr.replace(RE_QBMARK, function(_, pos) {
                    return qstr[pos].replace(/\r/g, "\\r").replace(/\n/g, "\\n");
                });
            }
            return expr;
        }
        var RE_BREND = {
            "(": /[()]/g,
            "[": /[[\]]/g,
            "{": /[{}]/g
        };
        function _parseExpr(expr, asText, qstr) {
            expr = expr.replace(RE_QBLOCK, function(s, div) {
                return s.length > 2 && !div ? CH_IDEXPR + (qstr.push(s) - 1) + "~" : s;
            }).replace(/\s+/g, " ").trim().replace(/\ ?([[\({},?\.:])\ ?/g, "$1");
            if (expr) {
                var list = [], cnt = 0, match;
                while (expr && (match = expr.match(RE_CSNAME)) && !match.index) {
                    var key, jsb, re = /,|([[{(])|$/g;
                    expr = RegExp.rightContext;
                    key = match[2] ? qstr[match[2]].slice(1, -1).trim().replace(/\s+/g, " ") : match[1];
                    while (jsb = (match = re.exec(expr))[1]) {
                        skipBraces(jsb, re);
                    }
                    jsb = expr.slice(0, match.index);
                    expr = RegExp.rightContext;
                    list[cnt++] = _wrapExpr(jsb, 1, key);
                }
                expr = !cnt ? _wrapExpr(expr, asText) : cnt > 1 ? "[" + list.join(",") + '].join(" ").trim()' : list[0];
            }
            return expr;
            function skipBraces(ch, re) {
                var mm, lv = 1, ir = RE_BREND[ch];
                ir.lastIndex = re.lastIndex;
                while (mm = ir.exec(expr)) {
                    if (mm[0] === ch) {
                        ++lv;
                    } else if (!--lv) {
                        break;
                    }
                }
                re.lastIndex = lv ? expr.length : ir.lastIndex;
            }
        }
        var JS_CONTEXT = '"in this?this:' + (typeof window !== "object" ? "global" : "window") + ").", JS_VARNAME = /[,{][\$\w]+(?=:)|(^ *|[^$\w\.{])(?!(?:typeof|true|false|null|undefined|in|instanceof|is(?:Finite|NaN)|void|NaN|new|Date|RegExp|Math)(?![$\w]))([$_A-Za-z][$\w]*)/g, JS_NOPROPS = /^(?=(\.[$\w]+))\1(?:[^.[(]|$)/;
        function _wrapExpr(expr, asText, key) {
            var tb;
            expr = expr.replace(JS_VARNAME, function(match, p, mvar, pos, s) {
                if (mvar) {
                    pos = tb ? 0 : pos + match.length;
                    if (mvar !== "this" && mvar !== "global" && mvar !== "window") {
                        match = p + '("' + mvar + JS_CONTEXT + mvar;
                        if (pos) {
                            tb = (s = s[pos]) === "." || s === "(" || s === "[";
                        }
                    } else if (pos) {
                        tb = !JS_NOPROPS.test(s.slice(pos));
                    }
                }
                return match;
            });
            if (tb) {
                expr = "try{return " + expr + "}catch(e){E(e,this)}";
            }
            if (key) {
                expr = (tb ? "function(){" + expr + "}.call(this)" : "(" + expr + ")") + '?"' + key + '":""';
            } else if (asText) {
                expr = "function(v){" + (tb ? expr.replace("return ", "v=") : "v=(" + expr + ")") + ';return v||v===0?v:""}.call(this)';
            }
            return expr;
        }
        _tmpl.version = brackets.version = "v3.0.3";
        return _tmpl;
    }();
    var observable$1 = function(el) {
        el = el || {};
        var callbacks = {}, slice = Array.prototype.slice;
        Object.defineProperties(el, {
            on: {
                value: function(event, fn) {
                    if (typeof fn == "function") {
                        (callbacks[event] = callbacks[event] || []).push(fn);
                    }
                    return el;
                },
                enumerable: false,
                writable: false,
                configurable: false
            },
            off: {
                value: function(event, fn) {
                    if (event == "*" && !fn) {
                        callbacks = {};
                    } else {
                        if (fn) {
                            var arr = callbacks[event];
                            for (var i = 0, cb; cb = arr && arr[i]; ++i) {
                                if (cb == fn) {
                                    arr.splice(i--, 1);
                                }
                            }
                        } else {
                            delete callbacks[event];
                        }
                    }
                    return el;
                },
                enumerable: false,
                writable: false,
                configurable: false
            },
            one: {
                value: function(event, fn) {
                    function on() {
                        el.off(event, on);
                        fn.apply(el, arguments);
                    }
                    return el.on(event, on);
                },
                enumerable: false,
                writable: false,
                configurable: false
            },
            trigger: {
                value: function(event) {
                    var arguments$1 = arguments;
                    var arglen = arguments.length - 1, args = new Array(arglen), fns, fn, i;
                    for (i = 0; i < arglen; i++) {
                        args[i] = arguments$1[i + 1];
                    }
                    fns = slice.call(callbacks[event] || [], 0);
                    for (i = 0; fn = fns[i]; ++i) {
                        fn.apply(el, args);
                    }
                    if (callbacks["*"] && event != "*") {
                        el.trigger.apply(el, [ "*", event ].concat(args));
                    }
                    return el;
                },
                enumerable: false,
                writable: false,
                configurable: false
            }
        });
        return el;
    };
    function each(list, fn) {
        var len = list ? list.length : 0;
        var i = 0;
        for (;i < len; ++i) {
            fn(list[i], i);
        }
        return list;
    }
    function contains(array, item) {
        return array.indexOf(item) !== -1;
    }
    function toCamel(str) {
        return str.replace(/-(\w)/g, function(_, c) {
            return c.toUpperCase();
        });
    }
    function startsWith(str, value) {
        return str.slice(0, value.length) === value;
    }
    function defineProperty(el, key, value, options) {
        Object.defineProperty(el, key, extend({
            value: value,
            enumerable: false,
            writable: false,
            configurable: true
        }, options));
        return el;
    }
    function extend(src) {
        var obj, args = arguments;
        for (var i = 1; i < args.length; ++i) {
            if (obj = args[i]) {
                for (var key in obj) {
                    if (isWritable(src, key)) {
                        src[key] = obj[key];
                    }
                }
            }
        }
        return src;
    }
    var misc = Object.freeze({
        each: each,
        contains: contains,
        toCamel: toCamel,
        startsWith: startsWith,
        defineProperty: defineProperty,
        extend: extend
    });
    var settings$1 = extend(Object.create(brackets.settings), {
        skipAnonymousTags: true
    });
    var EVENTS_PREFIX_REGEX = /^on/;
    function handleEvent(dom, handler, e) {
        var ptag = this.__.parent, item = this.__.item;
        if (!item) {
            while (ptag && !item) {
                item = ptag.__.item;
                ptag = ptag.__.parent;
            }
        }
        if (isWritable(e, "currentTarget")) {
            e.currentTarget = dom;
        }
        if (isWritable(e, "target")) {
            e.target = e.srcElement;
        }
        if (isWritable(e, "which")) {
            e.which = e.charCode || e.keyCode;
        }
        e.item = item;
        handler.call(this, e);
        if (!e.preventUpdate) {
            var p = getImmediateCustomParentTag(this);
            if (p.isMounted) {
                p.update();
            }
        }
    }
    function setEventHandler(name, handler, dom, tag) {
        var eventName, cb = handleEvent.bind(tag, dom, handler);
        dom[name] = null;
        eventName = name.replace(EVENTS_PREFIX_REGEX, "");
        if (!dom._riotEvents) {
            dom._riotEvents = {};
        }
        if (dom._riotEvents[name]) {
            dom.removeEventListener(eventName, dom._riotEvents[name]);
        }
        dom._riotEvents[name] = cb;
        dom.addEventListener(eventName, cb, false);
    }
    function updateDataIs(expr, parent) {
        var tagName = tmpl(expr.value, parent), conf, isVirtual, head, ref;
        if (expr.tag && expr.tagName === tagName) {
            expr.tag.update();
            return;
        }
        isVirtual = expr.dom.tagName === "VIRTUAL";
        if (expr.tag) {
            if (isVirtual) {
                head = expr.tag.__.head;
                ref = createDOMPlaceholder();
                head.parentNode.insertBefore(ref, head);
            }
            expr.tag.unmount(true);
        }
        expr.impl = __TAG_IMPL[tagName];
        conf = {
            root: expr.dom,
            parent: parent,
            hasImpl: true,
            tagName: tagName
        };
        expr.tag = initChildTag(expr.impl, conf, expr.dom.innerHTML, parent);
        each(expr.attrs, function(a) {
            return setAttr(expr.tag.root, a.name, a.value);
        });
        expr.tagName = tagName;
        expr.tag.mount();
        if (isVirtual) {
            makeReplaceVirtual(expr.tag, ref || expr.tag.root);
        }
        parent.__.onUnmount = function() {
            var delName = expr.tag.opts.dataIs, tags = expr.tag.parent.tags, _tags = expr.tag.__.parent.tags;
            arrayishRemove(tags, delName, expr.tag);
            arrayishRemove(_tags, delName, expr.tag);
            expr.tag.unmount();
        };
    }
    function updateExpression(expr) {
        if (this.root && getAttr(this.root, "virtualized")) {
            return;
        }
        var dom = expr.dom, attrName = expr.attr, isToggle = contains([ SHOW_DIRECTIVE, HIDE_DIRECTIVE ], attrName), value = tmpl(expr.expr, this), isValueAttr = attrName === "riot-value", isVirtual = expr.root && expr.root.tagName === "VIRTUAL", parent = dom && (expr.parent || dom.parentNode), old;
        if (expr.bool) {
            value = value ? attrName : false;
        } else if (isUndefined(value) || value === null) {
            value = "";
        }
        if (expr._riot_id) {
            if (expr.isMounted) {
                expr.update();
            } else {
                expr.mount();
                if (isVirtual) {
                    makeReplaceVirtual(expr, expr.root);
                }
            }
            return;
        }
        old = expr.value;
        expr.value = value;
        if (expr.update) {
            expr.update();
            return;
        }
        if (expr.isRtag && value) {
            return updateDataIs(expr, this);
        }
        if (old === value) {
            return;
        }
        if (isValueAttr && dom.value === value) {
            return;
        }
        if (!attrName) {
            value += "";
            if (parent) {
                expr.parent = parent;
                if (parent.tagName === "TEXTAREA") {
                    parent.value = value;
                    if (!IE_VERSION) {
                        dom.nodeValue = value;
                    }
                } else {
                    dom.nodeValue = value;
                }
            }
            return;
        }
        if (!expr.isAttrRemoved || !value) {
            remAttr(dom, attrName);
            expr.isAttrRemoved = true;
        }
        if (isFunction(value)) {
            setEventHandler(attrName, value, dom, this);
        } else if (isToggle) {
            if (attrName === HIDE_DIRECTIVE) {
                value = !value;
            }
            dom.style.display = value ? "" : "none";
        } else if (isValueAttr) {
            dom.value = value;
        } else if (startsWith(attrName, ATTRS_PREFIX) && attrName !== IS_DIRECTIVE) {
            attrName = attrName.slice(ATTRS_PREFIX.length);
            if (CASE_SENSITIVE_ATTRIBUTES[attrName]) {
                attrName = CASE_SENSITIVE_ATTRIBUTES[attrName];
            }
            if (value != null) {
                setAttr(dom, attrName, value);
            }
        } else {
            if (expr.bool) {
                dom[attrName] = value;
                if (!value) {
                    return;
                }
            }
            if (value === 0 || value && typeof value !== T_OBJECT) {
                setAttr(dom, attrName, value);
            }
        }
    }
    function updateAllExpressions(expressions) {
        each(expressions, updateExpression.bind(this));
    }
    var IfExpr = {
        init: function init(dom, tag, expr) {
            remAttr(dom, CONDITIONAL_DIRECTIVE);
            this.tag = tag;
            this.expr = expr;
            this.stub = document.createTextNode("");
            this.pristine = dom;
            var p = dom.parentNode;
            p.insertBefore(this.stub, dom);
            p.removeChild(dom);
            return this;
        },
        update: function update() {
            var newValue = tmpl(this.expr, this.tag);
            if (newValue && !this.current) {
                this.current = this.pristine.cloneNode(true);
                this.stub.parentNode.insertBefore(this.current, this.stub);
                this.expressions = [];
                parseExpressions.apply(this.tag, [ this.current, this.expressions, true ]);
            } else if (!newValue && this.current) {
                unmountAll(this.expressions);
                if (this.current._tag) {
                    this.current._tag.unmount();
                } else if (this.current.parentNode) {
                    this.current.parentNode.removeChild(this.current);
                }
                this.current = null;
                this.expressions = [];
            }
            if (newValue) {
                updateAllExpressions.call(this.tag, this.expressions);
            }
        },
        unmount: function unmount() {
            unmountAll(this.expressions || []);
            delete this.pristine;
            delete this.parentNode;
            delete this.stub;
        }
    };
    var RefExpr = {
        init: function init(dom, parent, attrName, attrValue) {
            this.dom = dom;
            this.attr = attrName;
            this.rawValue = attrValue;
            this.parent = parent;
            this.hasExp = tmpl.hasExpr(attrValue);
            this.firstRun = true;
            return this;
        },
        update: function update() {
            var value = this.rawValue;
            if (this.hasExp) {
                value = tmpl(this.rawValue, this.parent);
            }
            if (!this.firstRun && value === this.value) {
                return;
            }
            var customParent = this.parent && getImmediateCustomParentTag(this.parent);
            var tagOrDom = this.tag || this.dom;
            if (!isBlank(this.value) && customParent) {
                arrayishRemove(customParent.refs, this.value, tagOrDom);
            }
            if (isBlank(value)) {
                remAttr(this.dom, this.attr);
            } else {
                if (customParent) {
                    arrayishAdd(customParent.refs, value, tagOrDom, null, this.parent.__.index);
                }
                setAttr(this.dom, this.attr, value);
            }
            this.value = value;
            this.firstRun = false;
        },
        unmount: function unmount() {
            var tagOrDom = this.tag || this.dom;
            var customParent = this.parent && getImmediateCustomParentTag(this.parent);
            if (!isBlank(this.value) && customParent) {
                arrayishRemove(customParent.refs, this.value, tagOrDom);
            }
            delete this.dom;
            delete this.parent;
        }
    };
    function mkitem(expr, key, val, base) {
        var item = base ? Object.create(base) : {};
        item[expr.key] = key;
        if (expr.pos) {
            item[expr.pos] = val;
        }
        return item;
    }
    function unmountRedundant(items, tags) {
        var i = tags.length, j = items.length;
        while (i > j) {
            i--;
            remove.apply(tags[i], [ tags, i ]);
        }
    }
    function remove(tags, i) {
        tags.splice(i, 1);
        this.unmount();
        arrayishRemove(this.parent, this, this.__.tagName, true);
    }
    function moveNestedTags(i) {
        var this$1 = this;
        each(Object.keys(this.tags), function(tagName) {
            moveChildTag.apply(this$1.tags[tagName], [ tagName, i ]);
        });
    }
    function move(root, nextTag, isVirtual) {
        if (isVirtual) {
            moveVirtual.apply(this, [ root, nextTag ]);
        } else {
            safeInsert(root, this.root, nextTag.root);
        }
    }
    function insert(root, nextTag, isVirtual) {
        if (isVirtual) {
            makeVirtual.apply(this, [ root, nextTag ]);
        } else {
            safeInsert(root, this.root, nextTag.root);
        }
    }
    function append(root, isVirtual) {
        if (isVirtual) {
            makeVirtual.call(this, root);
        } else {
            root.appendChild(this.root);
        }
    }
    function _each(dom, parent, expr) {
        remAttr(dom, LOOP_DIRECTIVE);
        var mustReorder = typeof getAttr(dom, LOOP_NO_REORDER_DIRECTIVE) !== T_STRING || remAttr(dom, LOOP_NO_REORDER_DIRECTIVE), tagName = getTagName(dom), impl = __TAG_IMPL[tagName], parentNode = dom.parentNode, placeholder = createDOMPlaceholder(), child = getTag(dom), ifExpr = getAttr(dom, CONDITIONAL_DIRECTIVE), tags = [], oldItems = [], hasKeys, isLoop = true, isAnonymous = !__TAG_IMPL[tagName], isVirtual = dom.tagName === "VIRTUAL";
        expr = tmpl.loopKeys(expr);
        expr.isLoop = true;
        if (ifExpr) {
            remAttr(dom, CONDITIONAL_DIRECTIVE);
        }
        parentNode.insertBefore(placeholder, dom);
        parentNode.removeChild(dom);
        expr.update = function updateEach() {
            var items = tmpl(expr.val, parent), frag = createFrag(), isObject$$1 = !isArray(items) && !isString(items), root = placeholder.parentNode;
            if (isObject$$1) {
                hasKeys = items || false;
                items = hasKeys ? Object.keys(items).map(function(key) {
                    return mkitem(expr, items[key], key);
                }) : [];
            } else {
                hasKeys = false;
            }
            if (ifExpr) {
                items = items.filter(function(item, i) {
                    if (expr.key && !isObject$$1) {
                        return !!tmpl(ifExpr, mkitem(expr, item, i, parent));
                    }
                    return !!tmpl(ifExpr, extend(Object.create(parent), item));
                });
            }
            each(items, function(item, i) {
                var doReorder = mustReorder && typeof item === T_OBJECT && !hasKeys, oldPos = oldItems.indexOf(item), isNew = oldPos === -1, pos = !isNew && doReorder ? oldPos : i, tag = tags[pos], mustAppend = i >= oldItems.length, mustCreate = doReorder && isNew || !doReorder && !tag;
                item = !hasKeys && expr.key ? mkitem(expr, item, i) : item;
                if (mustCreate) {
                    tag = new Tag$1(impl, {
                        parent: parent,
                        isLoop: isLoop,
                        isAnonymous: isAnonymous,
                        tagName: tagName,
                        root: dom.cloneNode(isAnonymous),
                        item: item,
                        index: i
                    }, dom.innerHTML);
                    tag.mount();
                    if (mustAppend) {
                        append.apply(tag, [ frag || root, isVirtual ]);
                    } else {
                        insert.apply(tag, [ root, tags[i], isVirtual ]);
                    }
                    if (!mustAppend) {
                        oldItems.splice(i, 0, item);
                    }
                    tags.splice(i, 0, tag);
                    if (child) {
                        arrayishAdd(parent.tags, tagName, tag, true);
                    }
                } else if (pos !== i && doReorder) {
                    if (contains(items, oldItems[pos])) {
                        move.apply(tag, [ root, tags[i], isVirtual ]);
                        tags.splice(i, 0, tags.splice(pos, 1)[0]);
                        oldItems.splice(i, 0, oldItems.splice(pos, 1)[0]);
                    }
                    if (expr.pos) {
                        tag[expr.pos] = i;
                    }
                    if (!child && tag.tags) {
                        moveNestedTags.call(tag, i);
                    }
                }
                tag.__.item = item;
                tag.__.index = i;
                tag.__.parent = parent;
                if (!mustCreate) {
                    tag.update(item);
                }
            });
            unmountRedundant(items, tags);
            oldItems = items.slice();
            root.insertBefore(frag, placeholder);
        };
        expr.unmount = function() {
            each(tags, function(t) {
                t.unmount();
            });
        };
        return expr;
    }
    function parseExpressions(root, expressions, mustIncludeRoot) {
        var this$1 = this;
        var tree = {
            parent: {
                children: expressions
            }
        };
        walkNodes(root, function(dom, ctx) {
            var type = dom.nodeType, parent = ctx.parent, attr, expr, tagImpl;
            if (!mustIncludeRoot && dom === root) {
                return {
                    parent: parent
                };
            }
            if (type === 3 && dom.parentNode.tagName !== "STYLE" && tmpl.hasExpr(dom.nodeValue)) {
                parent.children.push({
                    dom: dom,
                    expr: dom.nodeValue
                });
            }
            if (type !== 1) {
                return ctx;
            }
            var isVirtual = dom.tagName === "VIRTUAL";
            if (attr = getAttr(dom, LOOP_DIRECTIVE)) {
                if (isVirtual) {
                    setAttr(dom, "loopVirtual", true);
                }
                parent.children.push(_each(dom, this$1, attr));
                return false;
            }
            if (attr = getAttr(dom, CONDITIONAL_DIRECTIVE)) {
                parent.children.push(Object.create(IfExpr).init(dom, this$1, attr));
                return false;
            }
            if (expr = getAttr(dom, IS_DIRECTIVE)) {
                if (tmpl.hasExpr(expr)) {
                    parent.children.push({
                        isRtag: true,
                        expr: expr,
                        dom: dom,
                        attrs: [].slice.call(dom.attributes)
                    });
                    return false;
                }
            }
            tagImpl = getTag(dom);
            if (isVirtual) {
                if (getAttr(dom, "virtualized")) {
                    dom.parentElement.removeChild(dom);
                }
                if (!tagImpl && !getAttr(dom, "virtualized") && !getAttr(dom, "loopVirtual")) {
                    tagImpl = {
                        tmpl: dom.outerHTML
                    };
                }
            }
            if (tagImpl && (dom !== root || mustIncludeRoot)) {
                if (isVirtual && !getAttr(dom, IS_DIRECTIVE)) {
                    setAttr(dom, "virtualized", true);
                    var tag = new Tag$1({
                        tmpl: dom.outerHTML
                    }, {
                        root: dom,
                        parent: this$1
                    }, dom.innerHTML);
                    parent.children.push(tag);
                } else {
                    var conf = {
                        root: dom,
                        parent: this$1,
                        hasImpl: true
                    };
                    parent.children.push(initChildTag(tagImpl, conf, dom.innerHTML, this$1));
                    return false;
                }
            }
            parseAttributes.apply(this$1, [ dom, dom.attributes, function(attr, expr) {
                if (!expr) {
                    return;
                }
                parent.children.push(expr);
            } ]);
            return {
                parent: parent
            };
        }, tree);
        return {
            tree: tree,
            root: root
        };
    }
    function parseAttributes(dom, attrs, fn) {
        var this$1 = this;
        each(attrs, function(attr) {
            var name = attr.name, bool = isBoolAttr(name), expr;
            if (contains(REF_DIRECTIVES, name)) {
                expr = Object.create(RefExpr).init(dom, this$1, name, attr.value);
            } else if (tmpl.hasExpr(attr.value)) {
                expr = {
                    dom: dom,
                    expr: attr.value,
                    attr: attr.name,
                    bool: bool
                };
            }
            fn(attr, expr);
        });
    }
    var reHasYield = /<yield\b/i;
    var reYieldAll = /<yield\s*(?:\/>|>([\S\s]*?)<\/yield\s*>|>)/gi;
    var reYieldSrc = /<yield\s+to=['"]([^'">]*)['"]\s*>([\S\s]*?)<\/yield\s*>/gi;
    var reYieldDest = /<yield\s+from=['"]?([-\w]+)['"]?\s*(?:\/>|>([\S\s]*?)<\/yield\s*>)/gi;
    var rootEls = {
        tr: "tbody",
        th: "tr",
        td: "tr",
        col: "colgroup"
    };
    var tblTags = IE_VERSION && IE_VERSION < 10 ? RE_SPECIAL_TAGS : RE_SPECIAL_TAGS_NO_OPTION;
    var GENERIC = "div";
    function specialTags(el, tmpl, tagName) {
        var select = tagName[0] === "o", parent = select ? "select>" : "table>";
        el.innerHTML = "<" + parent + tmpl.trim() + "</" + parent;
        parent = el.firstChild;
        if (select) {
            parent.selectedIndex = -1;
        } else {
            var tname = rootEls[tagName];
            if (tname && parent.childElementCount === 1) {
                parent = $(tname, parent);
            }
        }
        return parent;
    }
    function replaceYield(tmpl, html) {
        if (!reHasYield.test(tmpl)) {
            return tmpl;
        }
        var src = {};
        html = html && html.replace(reYieldSrc, function(_, ref, text) {
            src[ref] = src[ref] || text;
            return "";
        }).trim();
        return tmpl.replace(reYieldDest, function(_, ref, def) {
            return src[ref] || def || "";
        }).replace(reYieldAll, function(_, def) {
            return html || def || "";
        });
    }
    function mkdom(tmpl, html) {
        var match = tmpl && tmpl.match(/^\s*<([-\w]+)/), tagName = match && match[1].toLowerCase(), el = mkEl(GENERIC);
        tmpl = replaceYield(tmpl, html);
        if (tblTags.test(tagName)) {
            el = specialTags(el, tmpl, tagName);
        } else {
            setInnerHTML(el, tmpl);
        }
        return el;
    }
    function Tag$2(el, opts) {
        var ref = this;
        var name = ref.name;
        var tmpl = ref.tmpl;
        var css = ref.css;
        var attrs = ref.attrs;
        var onCreate = ref.onCreate;
        if (!__TAG_IMPL[name]) {
            tag$1(name, tmpl, css, attrs, onCreate);
            __TAG_IMPL[name].class = this.constructor;
        }
        mountTo(el, name, opts, this);
        if (css) {
            styleManager.inject();
        }
        return this;
    }
    function tag$1(name, tmpl, css, attrs, fn) {
        if (isFunction(attrs)) {
            fn = attrs;
            if (/^[\w\-]+\s?=/.test(css)) {
                attrs = css;
                css = "";
            } else {
                attrs = "";
            }
        }
        if (css) {
            if (isFunction(css)) {
                fn = css;
            } else {
                styleManager.add(css);
            }
        }
        name = name.toLowerCase();
        __TAG_IMPL[name] = {
            name: name,
            tmpl: tmpl,
            attrs: attrs,
            fn: fn
        };
        return name;
    }
    function tag2$1(name, tmpl, css, attrs, fn) {
        if (css) {
            styleManager.add(css, name);
        }
        __TAG_IMPL[name] = {
            name: name,
            tmpl: tmpl,
            attrs: attrs,
            fn: fn
        };
        return name;
    }
    function mount$1(selector, tagName, opts) {
        var tags = [];
        function pushTagsTo(root) {
            if (root.tagName) {
                var riotTag = getAttr(root, IS_DIRECTIVE);
                if (tagName && riotTag !== tagName) {
                    riotTag = tagName;
                    setAttr(root, IS_DIRECTIVE, tagName);
                }
                var tag = mountTo(root, riotTag || root.tagName.toLowerCase(), opts);
                if (tag) {
                    tags.push(tag);
                }
            } else if (root.length) {
                each(root, pushTagsTo);
            }
        }
        styleManager.inject();
        if (isObject(tagName)) {
            opts = tagName;
            tagName = 0;
        }
        var elem;
        var allTags;
        if (isString(selector)) {
            selector = selector === "*" ? allTags = selectTags() : selector + selectTags(selector.split(/, */));
            elem = selector ? $$(selector) : [];
        } else {
            elem = selector;
        }
        if (tagName === "*") {
            tagName = allTags || selectTags();
            if (elem.tagName) {
                elem = $$(tagName, elem);
            } else {
                var nodeList = [];
                each(elem, function(_el) {
                    return nodeList.push($$(tagName, _el));
                });
                elem = nodeList;
            }
            tagName = 0;
        }
        pushTagsTo(elem);
        return tags;
    }
    var mixins = {};
    var globals = mixins[GLOBAL_MIXIN] = {};
    var mixins_id = 0;
    function mixin$1(name, mix, g) {
        if (isObject(name)) {
            mixin$1("__unnamed_" + mixins_id++, name, true);
            return;
        }
        var store = g ? globals : mixins;
        if (!mix) {
            if (isUndefined(store[name])) {
                throw new Error("Unregistered mixin: " + name);
            }
            return store[name];
        }
        store[name] = isFunction(mix) ? extend(mix.prototype, store[name] || {}) && mix : extend(store[name] || {}, mix);
    }
    function update$1() {
        return each(__TAGS_CACHE, function(tag) {
            return tag.update();
        });
    }
    function unregister$1(name) {
        delete __TAG_IMPL[name];
    }
    var version = "v3.3.2";
    var core = Object.freeze({
        Tag: Tag$2,
        tag: tag$1,
        tag2: tag2$1,
        mount: mount$1,
        mixin: mixin$1,
        update: update$1,
        unregister: unregister$1,
        version: version
    });
    var __uid = 0;
    function updateOpts(isLoop, parent, isAnonymous, opts, instAttrs) {
        if (isLoop && isAnonymous) {
            return;
        }
        var ctx = !isAnonymous && isLoop ? this : parent || this;
        each(instAttrs, function(attr) {
            if (attr.expr) {
                updateAllExpressions.call(ctx, [ attr.expr ]);
            }
            opts[toCamel(attr.name)] = attr.expr ? attr.expr.value : attr.value;
        });
    }
    function Tag$1(impl, conf, innerHTML) {
        if (impl === void 0) impl = {};
        if (conf === void 0) conf = {};
        var opts = extend({}, conf.opts), parent = conf.parent, isLoop = conf.isLoop, isAnonymous = !!conf.isAnonymous, skipAnonymous = settings$1.skipAnonymousTags && isAnonymous, item = cleanUpData(conf.item), index = conf.index, instAttrs = [], implAttrs = [], expressions = [], root = conf.root, tagName = conf.tagName || getTagName(root), isVirtual = tagName === "virtual", propsInSyncWithParent = [], dom;
        if (!skipAnonymous) {
            observable$1(this);
        }
        if (impl.name && root._tag) {
            root._tag.unmount(true);
        }
        this.isMounted = false;
        defineProperty(this, "__", {
            isAnonymous: isAnonymous,
            instAttrs: instAttrs,
            innerHTML: innerHTML,
            tagName: tagName,
            index: index,
            isLoop: isLoop,
            virts: [],
            tail: null,
            head: null,
            parent: null,
            item: null
        });
        defineProperty(this, "_riot_id", ++__uid);
        defineProperty(this, "root", root);
        extend(this, {
            opts: opts
        }, item);
        defineProperty(this, "parent", parent || null);
        defineProperty(this, "tags", {});
        defineProperty(this, "refs", {});
        dom = isLoop && isAnonymous ? root : mkdom(impl.tmpl, innerHTML, isLoop);
        defineProperty(this, "update", function tagUpdate(data) {
            var nextOpts = {}, canTrigger = this.isMounted && !skipAnonymous;
            data = cleanUpData(data);
            extend(this, data);
            updateOpts.apply(this, [ isLoop, parent, isAnonymous, nextOpts, instAttrs ]);
            if (this.isMounted && isFunction(this.shouldUpdate) && !this.shouldUpdate(data, nextOpts)) {
                return this;
            }
            if (isLoop && isAnonymous) {
                inheritFrom.apply(this, [ this.parent, propsInSyncWithParent ]);
            }
            extend(opts, nextOpts);
            if (canTrigger) {
                this.trigger("update", data);
            }
            updateAllExpressions.call(this, expressions);
            if (canTrigger) {
                this.trigger("updated");
            }
            return this;
        }.bind(this));
        defineProperty(this, "mixin", function tagMixin() {
            var this$1 = this;
            each(arguments, function(mix) {
                var instance, obj;
                var props = [];
                var propsBlacklist = [ "init", "__proto__" ];
                mix = isString(mix) ? mixin$1(mix) : mix;
                if (isFunction(mix)) {
                    instance = new mix();
                } else {
                    instance = mix;
                }
                var proto = Object.getPrototypeOf(instance);
                do {
                    props = props.concat(Object.getOwnPropertyNames(obj || instance));
                } while (obj = Object.getPrototypeOf(obj || instance));
                each(props, function(key) {
                    if (!contains(propsBlacklist, key)) {
                        var descriptor = Object.getOwnPropertyDescriptor(instance, key) || Object.getOwnPropertyDescriptor(proto, key);
                        var hasGetterSetter = descriptor && (descriptor.get || descriptor.set);
                        if (!this$1.hasOwnProperty(key) && hasGetterSetter) {
                            Object.defineProperty(this$1, key, descriptor);
                        } else {
                            this$1[key] = isFunction(instance[key]) ? instance[key].bind(this$1) : instance[key];
                        }
                    }
                });
                if (instance.init) {
                    instance.init.bind(this$1)();
                }
            });
            return this;
        }.bind(this));
        defineProperty(this, "mount", function tagMount() {
            var this$1 = this;
            root._tag = this;
            parseAttributes.apply(parent, [ root, root.attributes, function(attr, expr) {
                if (!isAnonymous && RefExpr.isPrototypeOf(expr)) {
                    expr.tag = this$1;
                }
                attr.expr = expr;
                instAttrs.push(attr);
            } ]);
            implAttrs = [];
            walkAttrs(impl.attrs, function(k, v) {
                implAttrs.push({
                    name: k,
                    value: v
                });
            });
            parseAttributes.apply(this, [ root, implAttrs, function(attr, expr) {
                if (expr) {
                    expressions.push(expr);
                } else {
                    setAttr(root, attr.name, attr.value);
                }
            } ]);
            updateOpts.apply(this, [ isLoop, parent, isAnonymous, opts, instAttrs ]);
            var globalMixin = mixin$1(GLOBAL_MIXIN);
            if (globalMixin && !skipAnonymous) {
                for (var i in globalMixin) {
                    if (globalMixin.hasOwnProperty(i)) {
                        this$1.mixin(globalMixin[i]);
                    }
                }
            }
            if (impl.fn) {
                impl.fn.call(this, opts);
            }
            if (!skipAnonymous) {
                this.trigger("before-mount");
            }
            parseExpressions.apply(this, [ dom, expressions, isAnonymous ]);
            this.update(item);
            if (!isAnonymous) {
                while (dom.firstChild) {
                    root.appendChild(dom.firstChild);
                }
            }
            defineProperty(this, "root", root);
            defineProperty(this, "isMounted", true);
            if (skipAnonymous) {
                return;
            }
            if (!this.parent) {
                this.trigger("mount");
            } else {
                var p = getImmediateCustomParentTag(this.parent);
                p.one(!p.isMounted ? "mount" : "updated", function() {
                    this$1.trigger("mount");
                });
            }
            return this;
        }.bind(this));
        defineProperty(this, "unmount", function tagUnmount(mustKeepRoot) {
            var this$1 = this;
            var el = this.root, p = el.parentNode, ptag, tagIndex = __TAGS_CACHE.indexOf(this);
            if (!skipAnonymous) {
                this.trigger("before-unmount");
            }
            walkAttrs(impl.attrs, function(name) {
                if (startsWith(name, ATTRS_PREFIX)) {
                    name = name.slice(ATTRS_PREFIX.length);
                }
                remAttr(root, name);
            });
            if (tagIndex !== -1) {
                __TAGS_CACHE.splice(tagIndex, 1);
            }
            if (p || isVirtual) {
                if (parent) {
                    ptag = getImmediateCustomParentTag(parent);
                    if (isVirtual) {
                        Object.keys(this.tags).forEach(function(tagName) {
                            arrayishRemove(ptag.tags, tagName, this$1.tags[tagName]);
                        });
                    } else {
                        arrayishRemove(ptag.tags, tagName, this);
                        if (parent !== ptag) {
                            arrayishRemove(parent.tags, tagName, this);
                        }
                    }
                } else {
                    while (el.firstChild) {
                        el.removeChild(el.firstChild);
                    }
                }
                if (p) {
                    if (!mustKeepRoot) {
                        p.removeChild(el);
                    } else {
                        remAttr(p, IS_DIRECTIVE);
                    }
                }
            }
            if (this.__.virts) {
                each(this.__.virts, function(v) {
                    if (v.parentNode) {
                        v.parentNode.removeChild(v);
                    }
                });
            }
            unmountAll(expressions);
            each(instAttrs, function(a) {
                return a.expr && a.expr.unmount && a.expr.unmount();
            });
            if (this.__.onUnmount) {
                this.__.onUnmount();
            }
            if (!skipAnonymous) {
                this.trigger("unmount");
                this.off("*");
            }
            defineProperty(this, "isMounted", false);
            delete this.root._tag;
            return this;
        }.bind(this));
    }
    function getTag(dom) {
        return dom.tagName && __TAG_IMPL[getAttr(dom, IS_DIRECTIVE) || getAttr(dom, IS_DIRECTIVE) || dom.tagName.toLowerCase()];
    }
    function inheritFrom(target, propsInSyncWithParent) {
        var this$1 = this;
        each(Object.keys(target), function(k) {
            var mustSync = !isReservedName(k) && contains(propsInSyncWithParent, k);
            if (isUndefined(this$1[k]) || mustSync) {
                if (!mustSync) {
                    propsInSyncWithParent.push(k);
                }
                this$1[k] = target[k];
            }
        });
    }
    function moveChildTag(tagName, newPos) {
        var parent = this.parent, tags;
        if (!parent) {
            return;
        }
        tags = parent.tags[tagName];
        if (isArray(tags)) {
            tags.splice(newPos, 0, tags.splice(tags.indexOf(this), 1)[0]);
        } else {
            arrayishAdd(parent.tags, tagName, this);
        }
    }
    function initChildTag(child, opts, innerHTML, parent) {
        var tag = new Tag$1(child, opts, innerHTML), tagName = opts.tagName || getTagName(opts.root, true), ptag = getImmediateCustomParentTag(parent);
        defineProperty(tag, "parent", ptag);
        tag.__.parent = parent;
        arrayishAdd(ptag.tags, tagName, tag);
        if (ptag !== parent) {
            arrayishAdd(parent.tags, tagName, tag);
        }
        opts.root.innerHTML = "";
        return tag;
    }
    function getImmediateCustomParentTag(tag) {
        var ptag = tag;
        while (ptag.__.isAnonymous) {
            if (!ptag.parent) {
                break;
            }
            ptag = ptag.parent;
        }
        return ptag;
    }
    function unmountAll(expressions) {
        each(expressions, function(expr) {
            if (expr instanceof Tag$1) {
                expr.unmount(true);
            } else if (expr.unmount) {
                expr.unmount();
            }
        });
    }
    function getTagName(dom, skipDataIs) {
        var child = getTag(dom), namedTag = !skipDataIs && getAttr(dom, IS_DIRECTIVE);
        return namedTag && !tmpl.hasExpr(namedTag) ? namedTag : child ? child.name : dom.tagName.toLowerCase();
    }
    function cleanUpData(data) {
        if (!(data instanceof Tag$1) && !(data && isFunction(data.trigger))) {
            return data;
        }
        var o = {};
        for (var key in data) {
            if (!RE_RESERVED_NAMES.test(key)) {
                o[key] = data[key];
            }
        }
        return o;
    }
    function arrayishAdd(obj, key, value, ensureArray, index) {
        var dest = obj[key];
        var isArr = isArray(dest);
        var hasIndex = !isUndefined(index);
        if (dest && dest === value) {
            return;
        }
        if (!dest && ensureArray) {
            obj[key] = [ value ];
        } else if (!dest) {
            obj[key] = value;
        } else {
            if (isArr) {
                var oldIndex = dest.indexOf(value);
                if (oldIndex === index) {
                    return;
                }
                if (oldIndex !== -1) {
                    dest.splice(oldIndex, 1);
                }
                if (hasIndex) {
                    dest.splice(index, 0, value);
                } else {
                    dest.push(value);
                }
            } else {
                obj[key] = [ dest, value ];
            }
        }
    }
    function arrayishRemove(obj, key, value, ensureArray) {
        if (isArray(obj[key])) {
            var index = obj[key].indexOf(value);
            if (index !== -1) {
                obj[key].splice(index, 1);
            }
            if (!obj[key].length) {
                delete obj[key];
            } else if (obj[key].length === 1 && !ensureArray) {
                obj[key] = obj[key][0];
            }
        } else {
            delete obj[key];
        }
    }
    function mountTo(root, tagName, opts, ctx) {
        var impl = __TAG_IMPL[tagName], implClass = __TAG_IMPL[tagName].class, tag = ctx || (implClass ? Object.create(implClass.prototype) : {}), innerHTML = root._innerHTML = root._innerHTML || root.innerHTML;
        root.innerHTML = "";
        var conf = extend({
            root: root,
            opts: opts
        }, {
            parent: opts ? opts.parent : null
        });
        if (impl && root) {
            Tag$1.apply(tag, [ impl, conf, innerHTML ]);
        }
        if (tag && tag.mount) {
            tag.mount(true);
            if (!contains(__TAGS_CACHE, tag)) {
                __TAGS_CACHE.push(tag);
            }
        }
        return tag;
    }
    function makeReplaceVirtual(tag, ref) {
        var frag = createFrag();
        makeVirtual.call(tag, frag);
        ref.parentNode.replaceChild(frag, ref);
    }
    function makeVirtual(src, target) {
        var this$1 = this;
        var head = createDOMPlaceholder(), tail = createDOMPlaceholder(), frag = createFrag(), sib, el;
        this.root.insertBefore(head, this.root.firstChild);
        this.root.appendChild(tail);
        this.__.head = el = head;
        this.__.tail = tail;
        while (el) {
            sib = el.nextSibling;
            frag.appendChild(el);
            this$1.__.virts.push(el);
            el = sib;
        }
        if (target) {
            src.insertBefore(frag, target.__.head);
        } else {
            src.appendChild(frag);
        }
    }
    function moveVirtual(src, target) {
        var this$1 = this;
        var el = this.__.head, frag = createFrag(), sib;
        while (el) {
            sib = el.nextSibling;
            frag.appendChild(el);
            el = sib;
            if (el === this$1.__.tail) {
                frag.appendChild(el);
                src.insertBefore(frag, target.__.head);
                break;
            }
        }
    }
    function selectTags(tags) {
        if (!tags) {
            var keys = Object.keys(__TAG_IMPL);
            return keys + selectTags(keys);
        }
        return tags.filter(function(t) {
            return !/[^-\w]/.test(t);
        }).reduce(function(list, t) {
            var name = t.trim().toLowerCase();
            return list + ",[" + IS_DIRECTIVE + '="' + name + '"]';
        }, "");
    }
    var tags = Object.freeze({
        getTag: getTag,
        inheritFrom: inheritFrom,
        moveChildTag: moveChildTag,
        initChildTag: initChildTag,
        getImmediateCustomParentTag: getImmediateCustomParentTag,
        unmountAll: unmountAll,
        getTagName: getTagName,
        cleanUpData: cleanUpData,
        arrayishAdd: arrayishAdd,
        arrayishRemove: arrayishRemove,
        mountTo: mountTo,
        makeReplaceVirtual: makeReplaceVirtual,
        makeVirtual: makeVirtual,
        moveVirtual: moveVirtual,
        selectTags: selectTags
    });
    var settings = settings$1;
    var util = {
        tmpl: tmpl,
        brackets: brackets,
        styleManager: styleManager,
        vdom: __TAGS_CACHE,
        styleNode: styleManager.styleNode,
        dom: dom,
        check: check,
        misc: misc,
        tags: tags
    };
    var Tag$$1 = Tag$2;
    var tag$$1 = tag$1;
    var tag2$$1 = tag2$1;
    var mount$$1 = mount$1;
    var mixin$$1 = mixin$1;
    var update$$1 = update$1;
    var unregister$$1 = unregister$1;
    var observable = observable$1;
    var riot$1 = extend({}, core, {
        observable: observable$1,
        settings: settings,
        util: util
    });
    exports.settings = settings;
    exports.util = util;
    exports.Tag = Tag$$1;
    exports.tag = tag$$1;
    exports.tag2 = tag2$$1;
    exports.mount = mount$$1;
    exports.mixin = mixin$$1;
    exports.update = update$$1;
    exports.unregister = unregister$$1;
    exports.observable = observable;
    exports["default"] = riot$1;
    Object.defineProperty(exports, "__esModule", {
        value: true
    });
});

(function(root, factory) {
    if (typeof exports !== "undefined") {
        if (typeof module !== "undefined" && module.exports) {
            exports = module.exports = factory(root, exports);
        }
    } else if (typeof define === "function" && define.amd) {
        define([ "exports" ], function(exports) {
            root.Lockr = factory(root, exports);
        });
    } else {
        root.Lockr = factory(root, {});
    }
})(this, function(root, Lockr) {
    "use strict";
    if (!Array.prototype.indexOf) {
        Array.prototype.indexOf = function(elt) {
            var len = this.length >>> 0;
            var from = Number(arguments[1]) || 0;
            from = from < 0 ? Math.ceil(from) : Math.floor(from);
            if (from < 0) from += len;
            for (;from < len; from++) {
                if (from in this && this[from] === elt) return from;
            }
            return -1;
        };
    }
    Lockr.prefix = "";
    Lockr._getPrefixedKey = function(key, options) {
        options = options || {};
        if (options.noPrefix) {
            return key;
        } else {
            return this.prefix + key;
        }
    };
    Lockr.set = function(key, value, options) {
        var query_key = this._getPrefixedKey(key, options);
        try {
            localStorage.setItem(query_key, JSON.stringify({
                data: value
            }));
        } catch (e) {
            if (console) console.warn("Lockr didn't successfully save the '{" + key + ": " + value + "}' pair, because the localStorage is full.");
        }
    };
    Lockr.get = function(key, missing, options) {
        var query_key = this._getPrefixedKey(key, options), value;
        try {
            value = JSON.parse(localStorage.getItem(query_key));
        } catch (e) {
            try {
                if (localStorage[query_key]) {
                    value = JSON.parse('{"data":"' + localStorage.getItem(query_key) + '"}');
                } else {
                    value = null;
                }
            } catch (e) {
                if (console) console.warn("Lockr could not load the item with key " + key);
            }
        }
        if (value === null) {
            return missing;
        } else if (typeof value.data !== "undefined") {
            return value.data;
        } else {
            return missing;
        }
    };
    Lockr.sadd = function(key, value, options) {
        var query_key = this._getPrefixedKey(key, options), json;
        var values = Lockr.smembers(key);
        if (values.indexOf(value) > -1) {
            return null;
        }
        try {
            values.push(value);
            json = JSON.stringify({
                data: values
            });
            localStorage.setItem(query_key, json);
        } catch (e) {
            console.log(e);
            if (console) console.warn("Lockr didn't successfully add the " + value + " to " + key + " set, because the localStorage is full.");
        }
    };
    Lockr.smembers = function(key, options) {
        var query_key = this._getPrefixedKey(key, options), value;
        try {
            value = JSON.parse(localStorage.getItem(query_key));
        } catch (e) {
            value = null;
        }
        if (value === null) return []; else return value.data || [];
    };
    Lockr.sismember = function(key, value, options) {
        var query_key = this._getPrefixedKey(key, options);
        return Lockr.smembers(key).indexOf(value) > -1;
    };
    Lockr.getAll = function() {
        var keys = Object.keys(localStorage);
        return keys.map(function(key) {
            return Lockr.get(key);
        });
    };
    Lockr.srem = function(key, value, options) {
        var query_key = this._getPrefixedKey(key, options), json, index;
        var values = Lockr.smembers(key, value);
        index = values.indexOf(value);
        if (index > -1) values.splice(index, 1);
        json = JSON.stringify({
            data: values
        });
        try {
            localStorage.setItem(query_key, json);
        } catch (e) {
            if (console) console.warn("Lockr couldn't remove the " + value + " from the set " + key);
        }
    };
    Lockr.rm = function(key) {
        localStorage.removeItem(key);
    };
    Lockr.flush = function() {
        localStorage.clear();
    };
    return Lockr;
});

var slice = [].slice;

Zepto.extend(Zepto.ajaxSettings, {
    type: "GET",
    dataType: "json",
    contentType: "application/json",
    accept: "application/json",
    beforeSend: function(xhr, settings) {
        var token;
        Kor.ajax_loading();
        xhr.then(function() {
            return console.log("ajax log", xhr.requestUrl, JSON.parse(xhr.response));
        });
        xhr.requestUrl = settings.url;
        token = Zepto("meta[name=csrf-token]").attr("content");
        return xhr.setRequestHeader("X-CSRF-Token", token);
    },
    complete: function(xhr) {
        return Kor.ajax_not_loading();
    }
});

$.ajaxSetup({
    dataType: "json",
    beforeSend: function(xhr) {
        return Kor.ajax_loading();
    },
    complete: function(xhr) {
        return Kor.ajax_not_loading();
    }
});

window.wApp = {
    bus: riot.observable(),
    data: {},
    mixins: {}
};

Zepto.ajax({
    url: "/api/1.0/info",
    success: function(data) {
        window.wApp.data = data;
        return riot.update();
    }
});

wApp.bubbling_events = [];

riot.mixin("bubble", {
    init: function() {
        var event_name, j, len, ref, results, tag;
        tag = this;
        ref = wApp.bubbling_events;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
            event_name = ref[j];
            results.push(tag.on(event_name, function() {
                var args, ref1;
                args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
                if (tag.parent) {
                    return (ref1 = tag.parent).trigger.apply(ref1, [ event_name ].concat(slice.call(args)));
                }
            }));
        }
        return results;
    }
});

wApp.i18n = {
    translate: function(input, options) {
        var count, error, j, key, len, part, parts, ref, regex, result, tvalue, value;
        if (options == null) {
            options = {};
        }
        try {
            options.count || (options.count = 1);
            parts = input.split(".");
            result = wApp.data.translations[wApp.data.locale];
            for (j = 0, len = parts.length; j < len; j++) {
                part = parts[j];
                result = result[part];
            }
            count = options.count === 1 ? "one" : "other";
            result = result[count] || result;
            ref = options.interpolations;
            for (key in ref) {
                value = ref[key];
                regex = new RegExp("%{" + key + "}", "g");
                tvalue = wApp.i18n.translate(value);
                if (tvalue && tvalue !== value) {
                    value = tvalue;
                }
                result = result.replace(regex, value);
            }
            if (options.capitalize) {
                result = wApp.utils.capitalize(result);
            }
            return result;
        } catch (error1) {
            error = error1;
            return "";
        }
    }
};

wApp.i18n.t = wApp.i18n.translate;

wApp.routing = {
    query: function(params) {
        var k, qs, result, v;
        if (params) {
            result = {};
            $.extend(result, wApp.routing.query(), params);
            qs = [];
            for (k in result) {
                v = result[k];
                if (result[k] !== null && result[k] !== "") {
                    qs.push(k + "=" + v);
                }
            }
            return riot.route(self.routing.path() + "?" + qs.join("&"));
        } else {
            return wApp.routing.parts()["hash_query"] || {};
        }
    },
    path: function(new_path) {
        if (new_path) {
            return riot.route(new_path);
        } else {
            return wApp.routing.parts()["hash_path"];
        }
    },
    parts: function() {
        var cs, h, hash_query_string, j, kv, l, len, len1, pair, ref, ref1, result;
        if (!wApp.routing.parts_cache) {
            h = document.location.href;
            cs = h.match(/^(https?):\/\/([^\/]+)([^?#]+)?(?:\?([^#]+))?(?:#(.*))?$/);
            result = {
                href: h,
                scheme: cs[1],
                host: cs[2],
                path: cs[3],
                query_string: cs[4],
                query: {},
                hash: cs[5],
                hash_query: {}
            };
            if (result.query_string) {
                ref = result.query_string.split("&");
                for (j = 0, len = ref.length; j < len; j++) {
                    pair = ref[j];
                    kv = pair.split("=");
                    result.query[kv[0]] = kv[1];
                }
            }
            if (result.hash) {
                result.hash_path = result.hash.split("?")[0];
                if (hash_query_string = result.hash.split("?")[1]) {
                    ref1 = hash_query_string.split("&");
                    for (l = 0, len1 = ref1.length; l < len1; l++) {
                        pair = ref1[l];
                        kv = pair.split("=");
                        result.hash_query[kv[0]] = kv[1];
                    }
                }
            }
            wApp.routing.parts_cache = result;
        }
        return wApp.routing.parts_cache;
    },
    setup: function() {
        if (!wApp.routing.route) {
            wApp.routing.route = riot.route.create();
            riot.route.base("#/");
            wApp.routing.route("..", function() {
                var old_parts;
                old_parts = wApp.routing.parts();
                if (document.location.href !== old_parts["href"]) {
                    wApp.routing.parts_cache = null;
                    wApp.bus.trigger("routing:href", wApp.routing.parts());
                    if (old_parts["hash_path"] !== wApp.routing.path()) {
                        return wApp.bus.trigger("routing:path", wApp.routing.parts());
                    } else {
                        return wApp.bus.trigger("routing:query", wApp.routing.parts());
                    }
                }
            });
            riot.route.start(true);
            return wApp.bus.trigger("routing:path", wApp.routing.parts());
        }
    }
};

wApp.utils = {
    shorten: function(str, n) {
        if (n == null) {
            n = 15;
        }
        if (str && str.length > n) {
            return str.substr(0, n - 1) + "&hellip;";
        } else {
            return str;
        }
    },
    in_groups_of: function(per_row, array, dummy) {
        var current, i, j, len, result;
        if (dummy == null) {
            dummy = null;
        }
        result = [];
        current = [];
        for (j = 0, len = array.length; j < len; j++) {
            i = array[j];
            if (current.length === per_row) {
                result.push(current);
                current = [];
            }
            current.push(i);
        }
        if (current.length > 0) {
            if (dummy) {
                while (current.length < per_row) {
                    current.push(dummy);
                }
            }
            result.push(current);
        }
        return result;
    },
    to_integer: function(value) {
        if ($.isNumeric(value)) {
            return parseInt(value);
        } else {
            return value;
        }
    },
    capitalize: function(value) {
        return value.charAt(0).toUpperCase() + value.slice(1);
    },
    confirm: function(string) {
        return window.confirm(string);
    }
};

riot.tag2("kor-application", '<div class="container"> <a href="#/login">login</a> <a href="#/welcome">welcome</a> <a href="#/search">search</a> <a href="#/logout">logout</a> </div> <kor-js-extensions></kor-js-extensions> <kor-router></kor-router> <kor-notifications></kor-notifications> <div id="page-container" class="container"> <kor-page class="kor-appear-animation"></kor-page> </div>', "", "", function(opts) {
    var mount_page, tag;
    tag = this;
    window.kor = {
        url: tag.opts.baseUrl || "",
        bus: riot.observable(),
        load_session: function() {
            return Zepto.ajax({
                type: "get",
                url: kor.url + "/api/1.0/info",
                success: function(data) {
                    kor.info = data;
                    return kor.bus.trigger("data.info");
                }
            });
        },
        login: function(username, password) {
            console.log(arguments);
            return Zepto.ajax({
                type: "post",
                url: kor.url + "/login",
                data: JSON.stringify({
                    username: username,
                    password: password
                }),
                success: function(data) {
                    return kor.load_session();
                }
            });
        },
        logout: function() {
            return Zepto.ajax({
                type: "delete",
                url: kor.url + "/logout",
                success: function() {
                    return kor.load_session();
                }
            });
        }
    };
    riot.mixin({
        kor: kor
    });
    Zepto.extend(Zepto.ajaxSettings, {
        contentType: "application/json",
        dataType: "json",
        error: function(request) {
            console.log(request);
            return kor.bus.trigger("notify", JSON.parse(request.response));
        }
    });
    mount_page = function(tag) {
        var element;
        if (tag.mounted_page !== tag) {
            if (tag.page_tag) {
                tag.page_tag.unmount(true);
            }
            element = Zepto(tag.root).find("kor-page");
            tag.page_tag = riot.mount(element[0], tag)[0];
            element.detach();
            Zepto(tag["page-container"]).append(element);
            return tag.mounted_page = tag;
        }
    };
    tag.on("mount", function() {
        mount_page("kor-loading");
        return kor.load_session();
    });
    kor.bus.on("page.welcome", function() {
        return mount_page("kor-welcome");
    });
    kor.bus.on("page.login", function() {
        return mount_page("kor-login");
    });
    kor.bus.on("page.entity", function() {
        return mount_page("kor-entity");
    });
    kor.bus.on("page.search", function() {
        return mount_page("kor-search");
    });
});

riot.tag2("kor-entity-editor", '<h1>Entity Editor</h1> <div class="hr"></div> <form> <kor-field field-id="name" label-key="entity.name" model="{opts.entity}" errors="{errors.name}"></kor-field> <kor-field field-id="distinct_name" label-key="entity.distinct_name" model="{opts.entity}" errors="{errors.distinct_name}"></kor-field> <kor-field field-id="distinct_name" label-key="entity.distinct_name" model="{opts.entity}" errors="{errors.distinct_name}"></kor-field> </form>', "", "", function(opts) {
    var tag;
    tag = this;
});

riot.tag2("kor-field-editor", '<h2> <kor-t key="objects.edit" with="{{\'interpolations\': {\'o\': wApp.i18n.translate(\'activerecord.models.field\', {count: \'other\'})}}}" show="{opts.kind.id}"></kor-t> </h2> <form if="{showForm && types}" onsubmit="{submit}"> <kor-field field-id="type" label-key="field.type" type="select" options="{types_for_select}" allow-no-selection="{false}" model="{field}" onchange="{updateSpecialFields}" is-disabled="{field.id}"></kor-field> <virtual each="{f in specialFields}"> <kor-field field-id="{f.name}" label="{f.label}" model="{field}" errors="{errors[f.name]}"></kor-field> </virtual> <kor-field field-id="name" label-key="field.name" model="{field}" errors="{errors.name}"></kor-field> <kor-field field-id="show_label" label-key="field.show_label" model="{field}" errors="{errors.show_label}"></kor-field> <kor-field field-id="form_label" label-key="field.form_label" model="{field}" errors="{errors.form_label}"></kor-field> <kor-field field-id="search_label" label-key="field.search_label" model="{field}" errors="{errors.search_label}"></kor-field> <kor-field field-id="show_on_entity" type="checkbox" label-key="field.show_on_entity" model="{field}"></kor-field> <kor-field field-id="is_identifier" type="checkbox" label-key="field.is_identifier" model="{field}"></kor-field> <div class="hr"></div> <kor-submit></kor-submit> </form>', "", "", function(opts) {
    var create, params, tag, update;
    tag = this;
    tag.errors = {};
    tag.opts.notify.on("add-field", function() {
        tag.field = {
            type: "Fields::String"
        };
        tag.showForm = true;
        return tag.updateSpecialFields();
    });
    tag.opts.notify.on("edit-field", function(field) {
        tag.field = field;
        tag.showForm = true;
        return tag.updateSpecialFields();
    });
    tag.on("mount", function() {
        return Zepto.ajax({
            url: "/kinds/" + tag.opts.kind.id + "/fields/types",
            success: function(data) {
                var i, len, t;
                tag.types = {};
                tag.types_for_select = [];
                for (i = 0, len = data.length; i < len; i++) {
                    t = data[i];
                    tag.types_for_select.push({
                        value: t.name,
                        label: t.label
                    });
                    tag.types[t.name] = t;
                }
                return tag.updateSpecialFields();
            }
        });
    });
    tag.updateSpecialFields = function(event) {
        var typeName, types;
        if (tag.showForm) {
            typeName = Zepto("[name=type]").val() || tag.field.type;
            tag.field.type = typeName;
            if (types = tag.types) {
                tag.specialFields = types[typeName].fields;
                tag.update();
            }
        }
        return true;
    };
    tag.submit = function(event) {
        event.preventDefault();
        if (tag.field.id) {
            return update();
        } else {
            return create();
        }
    };
    params = function() {
        var k, ref, results, t;
        results = {};
        ref = tag.formFields;
        for (k in ref) {
            t = ref[k];
            results[t.fieldId()] = t.val();
        }
        return {
            field: results,
            klass: results.type
        };
    };
    create = function() {
        return Zepto.ajax({
            type: "POST",
            url: "/kinds/" + tag.opts.kind.id + "/fields",
            data: JSON.stringify(params()),
            success: function() {
                tag.opts.notify.trigger("refresh");
                tag.errors = {};
                return tag.showForm = false;
            },
            error: function(request) {
                var data;
                data = JSON.parse(request.response);
                return tag.errors = data.record.errors;
            },
            complete: function() {
                return tag.update();
            }
        });
    };
    update = function() {
        console.log("updating");
        return Zepto.ajax({
            type: "PATCH",
            url: "/kinds/" + tag.opts.kind.id + "/fields/" + tag.field.id,
            data: JSON.stringify(params()),
            success: function() {
                tag.opts.notify.trigger("refresh");
                return tag.showForm = false;
            },
            error: function(request) {
                tag.field = request.responseJSON.record;
                return tag.field.errors = request.responseJSON.errors;
            },
            complete: function() {
                return tag.update();
            }
        });
    };
});

riot.tag2("kor-fields", '<div class="pull-right"> <a href="#/kinds/{opts.kind.id}/fields/new" onclick="{add}"> <i class="fa fa-plus-square"></i> </a> </div> <strong> <kor-t key="activerecord.models.field" with="{{count: \'other\', capitalize: true}}"> /> </strong> <ul if="{kind}"> <li each="{field in kind.fields}"> <div class="pull-right"> <a href="#" onclick="{edit(field)}"><i class="fa fa-edit"></i></a> <a href="#" onclick="{remove(field)}"><i class="fa fa-remove"></i></a> </div> <a href="#" onclick="{edit(field)}">{field.name}</a> </li> </ul> <div if="{ancestry}" each="{k in ancestry}" show="{k.fields.length}"> <strong> <kor-t key="inherited_from"></kor-t> {k.name} </strong> <ul> <li each="{field in k.fields}">{field.name}</li> </ul> </div>', "", "", function(opts) {
    var refresh, tag;
    tag = this;
    tag.on("mount", function() {
        return refresh();
    });
    tag.opts.notify.on("refresh", function() {
        return refresh();
    });
    tag.add = function(event) {
        event.preventDefault();
        return tag.opts.notify.trigger("add-field");
    };
    tag.edit = function(field) {
        return function(event) {
            event.preventDefault();
            return tag.opts.notify.trigger("edit-field", field);
        };
    };
    tag.remove = function(field) {
        return function(event) {
            event.preventDefault();
            if (wApp.utils.confirm(wApp.i18n.translate("confirm.general"))) {
                return Zepto.ajax({
                    type: "delete",
                    url: "/kinds/" + tag.opts.kind.id + "/fields/" + field.id,
                    success: function() {
                        return refresh();
                    }
                });
            }
        };
    };
    tag.build_ancestry = function() {
        var i, k, len, new_todo, result_ids, results, todo;
        results = [];
        result_ids = [];
        todo = tag.kind.parents;
        while (todo.length > 0) {
            new_todo = [];
            for (i = 0, len = todo.length; i < len; i++) {
                k = todo[i];
                if (result_ids.indexOf(k.id) === -1) {
                    results.push(k);
                    result_ids.push(k.id);
                    new_todo = new_todo.concat(k.parents);
                }
            }
            todo = new_todo;
        }
        return tag.ancestry = results;
    };
    refresh = function() {
        return Zepto.ajax({
            url: "/kinds/" + tag.opts.kind.id,
            data: {
                include: "fields,ancestry"
            },
            success: function(data) {
                tag.kind = data;
                tag.build_ancestry();
                return tag.update();
            }
        });
    };
});

riot.tag2("kor-generator-editor", '<h2> <kor-t key="objects.edit" with="{{\'interpolations\': {\'o\': wApp.i18n.translate(\'activerecord.models.generator\', {count: \'other\'})}}}" show="{opts.kind.id}"></kor-t> </h2> <form if="{showForm}" onsubmit="{submit}"> <kor-field field-id="name" label-key="generator.name" model="{generator}" errors="{errors.name}"></kor-field> <kor-field field-id="directive" label-key="generator.directive" type="textarea" model="{generator}" errors="{errors.directive}"></kor-field> <div class="hr"></div> <kor-submit></kor-submit> </form>', "", "", function(opts) {
    var create, params, tag, update;
    tag = this;
    tag.errors = {};
    tag.opts.notify.on("add-generator", function() {
        tag.generator = {};
        tag.showForm = true;
        return tag.update();
    });
    tag.opts.notify.on("edit-generator", function(generator) {
        tag.generator = generator;
        tag.showForm = true;
        return tag.update();
    });
    tag.submit = function(event) {
        event.preventDefault();
        if (tag.generator.id) {
            return update();
        } else {
            return create();
        }
    };
    create = function() {
        return Zepto.ajax({
            type: "POST",
            url: "/kinds/" + tag.opts.kind.id + "/generators",
            data: JSON.stringify(params()),
            success: function() {
                tag.opts.notify.trigger("refresh");
                tag.errors = {};
                return tag.showForm = false;
            },
            error: function(request) {
                var data;
                data = JSON.parse(request.response);
                return tag.errors = data.record.errors;
            },
            complete: function() {
                return tag.update();
            }
        });
    };
    update = function() {
        return Zepto.ajax({
            type: "PATCH",
            url: "/kinds/" + tag.opts.kind.id + "/generators/" + tag.generator.id,
            data: JSON.stringify(params()),
            success: function() {
                tag.opts.notify.trigger("refresh");
                return tag.showForm = false;
            },
            error: function(request) {
                return tag.generator = request.responseJSON.record;
            },
            complete: function() {
                return tag.update();
            }
        });
    };
    params = function() {
        var k, ref, results, t;
        results = {};
        ref = tag.formFields;
        for (k in ref) {
            t = ref[k];
            results[t.fieldId()] = t.val();
        }
        return {
            generator: results
        };
    };
});

riot.tag2("kor-generators", '<div class="pull-right"> <a href="#/kinds/{opts.kind.id}/generators/new" onclick="{add}"> <i class="fa fa-plus-square"></i> </a> </div> <strong> <kor-t key="activerecord.models.generator" with="{{count: \'other\', capitalize: true}}"> /> </strong> <ul if="{kind}"> <li each="{generator in kind.generators}"> <div class="pull-right"> <a href="#" onclick="{edit(generator)}"><i class="fa fa-edit"></i></a> <a href="#" onclick="{remove(generator)}"><i class="fa fa-remove"></i></a> </div> <a href="#" onclick="{edit(generator)}">{generator.name}</a> </li> </ul> <virtual if="{kind}"> <div each="{k in ancestry}" show="{k.generators.length > 0}"> <strong> <kor-t key="inherited_from"></kor-t> {k.name} </strong> <ul> <li each="{generator in k.generators}">{generator.name}</li> </ul> </div> </virtual>', "", "", function(opts) {
    var refresh, tag;
    tag = this;
    tag.on("mount", function() {
        return refresh();
    });
    tag.opts.notify.on("refresh", function() {
        return refresh();
    });
    tag.add = function(event) {
        event.preventDefault();
        return tag.opts.notify.trigger("add-generator");
    };
    tag.edit = function(generator) {
        return function(event) {
            event.preventDefault();
            return tag.opts.notify.trigger("edit-generator", generator);
        };
    };
    tag.remove = function(generator) {
        return function(event) {
            event.preventDefault();
            if (wApp.utils.confirm(wApp.i18n.translate("confirm.general"))) {
                return Zepto.ajax({
                    type: "delete",
                    url: "/kinds/" + tag.opts.kind.id + "/generators/" + generator.id,
                    success: function() {
                        return refresh();
                    }
                });
            }
        };
    };
    tag.build_ancestry = function() {
        var i, k, len, new_todo, result_ids, results, todo;
        results = [];
        result_ids = [];
        todo = tag.kind.parents;
        while (todo.length > 0) {
            new_todo = [];
            for (i = 0, len = todo.length; i < len; i++) {
                k = todo[i];
                if (result_ids.indexOf(k.id) === -1) {
                    results.push(k);
                    result_ids.push(k.id);
                    new_todo = new_todo.concat(k.parents);
                }
            }
            todo = new_todo;
        }
        return tag.ancestry = results;
    };
    refresh = function() {
        return Zepto.ajax({
            url: "/kinds/" + tag.opts.kind.id,
            data: {
                include: "generators,ancestry"
            },
            success: function(data) {
                tag.kind = data;
                tag.build_ancestry();
                return tag.update();
            }
        });
    };
});

riot.tag2("kor-kind-editor", '<kor-layout-panel class="left small" if="{opts.kind}"> <kor-panel> <h1> <span show="{opts.kind.id}">{opts.kind.name}</span> <kor-t show="{!opts.kind.id}" key="objects.create" with="{{\'interpolations\': {\'o\': wApp.i18n.translate(\'activerecord.models.kind\')}}}"></kor-t> </h1> <a href="#" onclick="{switchTo(\'general\')}"> » {wApp.i18n.translate(\'general\', {capitalize: true})} </a><br> <a href="#" onclick="{switchTo(\'fields\')}" if="{opts.kind.id}"> » {wApp.i18n.translate(\'activerecord.models.field\', {count: \'other\', capitalize: true})} </a><br> <a href="#" onclick="{switchTo(\'generators\')}" if="{opts.kind.id}"> » {wApp.i18n.translate(\'activerecord.models.generator\', {count: \'other\', capitalize: true})} </a><br> <div class="hr"></div> <div class="text-right"> <a href="#/kinds" class="kor-button">{wApp.i18n.t(\'back_to_list\')}</a> </div> <div class="hr" if="{tab == \'fields\' || tab == \'generators\'}"></div> <kor-fields kind="{opts.kind}" if="{tab == \'fields\'}" notify="{notify}"></kor-fields> <kor-generators kind="{opts.kind}" if="{tab == \'generators\'}" notify="{notify}"></kor-generators> </kor-panel> </kor-layout-panel> <kor-layout-panel class="right large"> <kor-panel> <kor-kind-general-editor if="{tab == \'general\'}" kind="{opts.kind}" notify="{notify}"></kor-kind-general-editor> <kor-field-editor kind="{opts.kind}" if="{tab == \'fields\' && opts.kind.id}" notify="{notify}"></kor-field-editor> <kor-generator-editor kind="{opts.kind}" if="{tab == \'generators\' && opts.kind.id}" notify="{notify}"></kor-generator-editor> </kor-panel> </kor-layout-panel>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.tab = "general";
    tag.notify = riot.observable();
    tag.on("mount", function() {
        if (tag.opts.id) {
            return Zepto.ajax({
                url: "/kinds/" + tag.opts.id,
                data: {
                    include: "fields,generators"
                },
                success: function(data) {
                    tag.opts.kind = data;
                    return tag.update();
                }
            });
        } else {
            return tag.opts.kind = {};
        }
    });
    tag.on("kind-changed", function(new_kind) {
        tag.opts.kind = new_kind;
        return tag.update();
    });
    tag.switchTo = function(name) {
        return function(event) {
            event.preventDefault();
            tag.tab = name;
            return tag.update();
        };
    };
    tag.closeModal = function() {
        if (tag.opts.modal) {
            tag.opts.modal.trigger("close");
            return window.location.reload();
        }
    };
});

riot.tag2("kor-kind-general-editor", '<h2> <kor-t key="general" with="{{capitalize: true}}" show="{opts.kind.id}"></kor-t> <kor-t show="{!opts.kind.id}" key="objects.create" with="{{\'interpolations\': {\'o\': wApp.i18n.translate(\'activerecord.models.kind\')}}}"></kor-t> </h2> <form onsubmit="{submit}" if="{possible_parents}"> <kor-field field-id="name" label-key="kind.name" model="{opts.kind}" errors="{errors.name}"></kor-field> <kor-field field-id="plural_name" label-key="kind.plural_name" model="{opts.kind}" errors="{errors.plural_name}"></kor-field> <kor-field field-id="description" type="textarea" label-key="kind.description" model="{opts.kind}"></kor-field> <kor-field field-id="url" label-key="kind.url" model="{opts.kind}"></kor-field> <kor-field field-id="parent_ids" type="select" options="{possible_parents}" multiple="{true}" label-key="kind.parent" model="{opts.kind}" errors="{errors.parent_ids}"></kor-field> <kor-field field-id="abstract" type="checkbox" label-key="kind.abstract" model="{opts.kind}"></kor-field> <kor-field field-id="tagging" type="checkbox" label-key="kind.tagging" model="{opts.kind}"></kor-field> <div if="{!is_media()}"> <kor-field field-id="dating_label" label-key="kind.dating_label" model="{opts.kind}"></kor-field> <kor-field field-id="name_label" label-key="kind.name_label" model="{opts.kind}"></kor-field> <kor-field field-id="distinct_name_label" label-key="kind.distinct_name_label" model="{opts.kind}"></kor-field> </div> <div class="hr"></div> <kor-submit></kor-submit> </form>', "", "", function(opts) {
    var error, success, tag;
    tag = this;
    tag.on("mount", function() {
        tag.errors = {};
        return Zepto.ajax({
            type: "get",
            url: "/kinds",
            success: function(data) {
                var i, kind, len, ref;
                tag.possible_parents = [];
                ref = data.records;
                for (i = 0, len = ref.length; i < len; i++) {
                    kind = ref[i];
                    if (!tag.opts.kind || tag.opts.kind.id !== kind.id && tag.opts.kind.id !== 1) {
                        tag.possible_parents.push({
                            label: kind.name,
                            value: kind.id
                        });
                    }
                }
                return tag.update();
            }
        });
    });
    tag.is_media = function() {
        return opts.kind && opts.kind.uuid === wApp.data.medium_kind_uuid;
    };
    tag.new_record = function() {
        return !(tag.opts.kind || {}).id;
    };
    tag.values = function() {
        var field, i, len, ref, result;
        result = {};
        ref = tag.tags["kor-field"];
        for (i = 0, len = ref.length; i < len; i++) {
            field = ref[i];
            result[field.fieldId()] = field.val();
        }
        return result;
    };
    success = function(data) {
        tag.parent.trigger("kind-changed", data.record);
        tag.errors = {};
        return tag.update();
    };
    error = function(response) {
        var data;
        data = JSON.parse(response.response);
        tag.errors = data.errors;
        tag.opts.kind = data.record;
        return tag.update();
    };
    tag.submit = function(event) {
        event.preventDefault();
        if (tag.new_record()) {
            return Zepto.ajax({
                type: "POST",
                url: "/kinds",
                data: JSON.stringify({
                    kind: tag.values()
                }),
                success: success,
                error: error
            });
        } else {
            return Zepto.ajax({
                type: "PATCH",
                url: "/kinds/" + tag.opts.kind.id,
                data: JSON.stringify({
                    kind: tag.values()
                }),
                success: success,
                error: error
            });
        }
    };
});

riot.tag2("kor-loading", "<span>... loading ...</span>", "", "", function(opts) {});

riot.tag2("kor-notifications", '<ul> <li each="{data in messages}" class="bg-warning {kor-fade-animation: data.remove}" onanimationend="{parent.animend}"> <i class="glyphicon glyphicon-exclamation-sign"></i> {data.message} </li> </ul>', "", "", function(opts) {
    var fading, tag;
    tag = this;
    tag.messages = [];
    tag.history = [];
    tag.animend = function(event) {
        var i;
        i = tag.messages.indexOf(event.item.data);
        tag.history.push(tag.messages[i]);
        tag.messages.splice(i, 1);
        return tag.update();
    };
    fading = function(data) {
        tag.messages.push(data);
        tag.update();
        return setTimeout(function() {
            data.remove = true;
            return tag.update();
        }, 5e3);
    };
    kor.bus.on("notify", function(data) {
        var type;
        type = data.type || "default";
        if (type === "default") {
            fading(data);
        }
        return tag.update();
    });
});

riot.tag2("kor-sub-menu", '<a href="#" onclick="{toggle}">{opts.label}</a> <div class="content" show="{visible()}"> <yield></yield> </div>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.visible = function() {
        return (Lockr.get("toggles") || {})[tag.opts.menuId];
    };
    tag.toggle = function(event) {
        var data;
        event.preventDefault();
        data = Lockr.get("toggles") || {};
        data[tag.opts.menuId] = !data[tag.opts.menuId];
        return Lockr.set("toggles", data);
    };
});

riot.tag2("kor-t", "", "", "", function(opts) {
    var tag;
    tag = this;
    tag.value = function() {
        return wApp.i18n.t(tag.opts.key, tag.opts["with"]);
    };
    tag.on("updated", function() {
        return Zepto(tag.root).html(tag.value());
    });
});

riot.tag2("kor-field", '<label> {label()} <input if="{has_input()}" type="{inputType()}" name="{opts.fieldId}" riot-value="{value()}" checked="{checked()}"> <textarea if="{has_textarea()}" name="{opts.fieldId}">{value()}</textarea> <select if="{has_select()}" name="{opts.fieldId}" multiple="{opts.multiple}" disabled="{opts.isDisabled}"> <option if="{opts.allowNoSelection}" riot-value="{undefined}" selected="{!!value()}">{noSelectionLabel()}</option> <option each="{o in opts.options}" riot-value="{o.value}" selected="{parent.selected(o.value)}">{o.label}</option> </select> <ul if="{has_errors()}" class="errors"> <li each="{error in errors()}">{error}</li> </ul> </label>', "", "class=\"{'errors': has_errors()}\"", function(opts) {
    var tag;
    tag = this;
    tag.on("mount", function() {
        var base;
        if (tag.parent) {
            (base = tag.parent).formFields || (base.formFields = {});
            return tag.parent.formFields[tag.fieldId()] = tag;
        }
    });
    tag.on("unmount", function() {
        var base;
        if (tag.parent) {
            (base = tag.parent).formFields || (base.formFields = {});
            return delete tag.parent.formFields[tag.fieldId()];
        }
    });
    tag.on("updated", function() {
        if (tag.has_select()) {
            return Zepto(tag.root).find("select option[selected]").prop("selected", true);
        }
    });
    tag.fieldId = function() {
        return tag.opts.fieldId;
    };
    tag.label = function() {
        var i, k, keys, len, result;
        if (tag.opts.label) {
            return tag.opts.label;
        } else if (tag.opts.labelKey) {
            keys = [ tag.opts.labelKey, "activerecord.attributes." + tag.opts.labelKey ];
            for (i = 0, len = keys.length; i < len; i++) {
                k = keys[i];
                if (result = wApp.i18n.t(k, {
                    capitalize: true
                })) {
                    return result;
                }
            }
        } else {
            return tag.fieldId();
        }
    };
    tag.inputType = function() {
        return opts.type || "text";
    };
    tag.has_input = function() {
        return !tag.has_textarea() && !tag.has_select();
    };
    tag.has_textarea = function() {
        return tag.inputType() === "textarea";
    };
    tag.has_select = function() {
        return tag.inputType() === "select";
    };
    tag.noSelectionLabel = function() {
        return tag.opts.noSelectionLabel || wApp.i18n.t("nothing_selected");
    };
    tag.checked = function() {
        if (tag.inputType() === "checkbox") {
            return tag.value();
        } else {
            return false;
        }
    };
    tag.selected = function(key) {
        if (tag.value()) {
            if (tag.opts.multiple) {
                return tag.value().indexOf(key) > -1;
            } else {
                return tag.value() === key;
            }
        }
    };
    tag.value = function() {
        return tag.opts.value || (tag.opts.model ? tag.opts.model[tag.opts.fieldId] : void 0);
    };
    tag.errors = function() {
        var m;
        return tag.opts.errors || ((m = tag.opts.model) ? (m.errors || {})[tag.opts.fieldId] || [] : []);
    };
    tag.has_errors = function() {
        return tag.errors().length > 0;
    };
    tag.val = function() {
        var element;
        element = Zepto(tag.root).find("input, textarea, select");
        if (tag.inputType() === "checkbox") {
            return element.prop("checked");
        } else {
            return element.val();
        }
    };
});

riot.tag2("kor-kinds", '<h1>{t(\'activerecord.models.kind\', {capitalize: true, count: \'other\'})}</h1> <form class="kor-horizontal"> <kor-field label-key="search_term" field-id="terms" onkeyup="{delayedSubmit}"></kor-field> <kor-field label-key="hide_abstract" type="checkbox" field-id="hideAbstract" onchange="{submit}"></kor-field> <div class="hr"></div> </form> <div class="text-right"> <a href="#/kinds/new"> <i class="fa fa-plus-square"></i> </a> </div> <table class="kor_table text-left" if="{filtered_records}"> <thead> <tr> <th>{wApp.i18n.t(\'activerecord.attributes.kind.name\')}</th> <th></th> </tr> </thead> <tbody> <tr each="{kind in filtered_records}"> <td class="{active: !kind.abstract}"> <div class="name"> <a href="#/kinds/{kind.id}">{kind.name}</a> </div> <div show="{kind.fields.length}"> <span class="label"> {t(\'activerecord.models.field\', {count: \'other\'})}: </span> {fieldNamesFor(kind)} </div> <div show="{kind.generators.length}"> <span class="label"> {t(\'activerecord.models.generator\', {count: \'other\'})}: </span> {generatorNamesFor(kind)} </div> </td> <td class="text-right buttons"> <a href="#/kinds/{kind.id}"><i class="fa fa-edit"></i></a> <a if="{kind.removable}" href="#/kinds/{kind.id}" onclick="{delete(kind)}"><i class="fa fa-remove"></i></a> </td> </tr> </tbody> </table>', "", "", function(opts) {
    var fetch, filter_records, index_records, tag;
    tag = this;
    tag.filters = {};
    tag.bus = riot.observable();
    tag.on("mount", function() {
        return fetch();
    });
    wApp.bus.on("kinds-changed", function() {
        return fetch();
    });
    tag.t = wApp.i18n.translate;
    tag["delete"] = function(kind) {
        return function(event) {
            event.preventDefault();
            if (wApp.utils.confirm(wApp.i18n.translate("confirm.general"))) {
                return Zepto.ajax({
                    type: "delete",
                    url: "/kinds/" + kind.id,
                    success: function() {
                        return wApp.bus.trigger("kinds-changed");
                    }
                });
            }
        };
    };
    tag.isMedia = function(kind) {
        return kind.uuid === wApp.data.medium_kind_uuid;
    };
    tag.fieldNamesFor = function(kind) {
        var k;
        return function() {
            var i, len, ref, results1;
            ref = kind.fields;
            results1 = [];
            for (i = 0, len = ref.length; i < len; i++) {
                k = ref[i];
                results1.push(k.show_label);
            }
            return results1;
        }().join(", ");
    };
    tag.generatorNamesFor = function(kind) {
        var g;
        return function() {
            var i, len, ref, results1;
            ref = kind.generators;
            results1 = [];
            for (i = 0, len = ref.length; i < len; i++) {
                g = ref[i];
                results1.push(g.name);
            }
            return results1;
        }().join(", ");
    };
    tag.submit = function() {
        tag.filters.terms = tag.formFields["terms"].val();
        tag.filters.hideAbstract = tag.formFields["hideAbstract"].val();
        filter_records();
        return tag.update();
    };
    tag.delayedSubmit = function(event) {
        if (tag.delayedTimeout) {
            tag.delayedTimeout.clearTimeout;
            tag.delayedTimeout = void 0;
        }
        tag.delayedTimeout = window.setTimeout(tag.submit, 300);
        return true;
    };
    index_records = function() {
        var i, kind, len, ref, results1;
        tag.lookup = {};
        tag.roots = [];
        ref = tag.data.records;
        results1 = [];
        for (i = 0, len = ref.length; i < len; i++) {
            kind = ref[i];
            tag.lookup[kind.id] = kind;
            if (kind.parent_ids.length === 0) {
                results1.push(tag.roots.push(kind));
            } else {
                results1.push(void 0);
            }
        }
        return results1;
    };
    filter_records = function() {
        var kind, re, results;
        tag.filtered_records = function() {
            var i, len, ref;
            if (tag.filters.terms) {
                re = new RegExp("" + tag.filters.terms, "i");
                results = [];
                ref = tag.data.records;
                for (i = 0, len = ref.length; i < len; i++) {
                    kind = ref[i];
                    if (kind.name.match(re)) {
                        if (results.indexOf(kind) === -1) {
                            results.push(kind);
                        }
                    }
                }
                return results;
            } else {
                return tag.data.records;
            }
        }();
        if (tag.filters.hideAbstract) {
            return tag.filtered_records = tag.filtered_records.filter(function(kind) {
                return !kind.abstract;
            });
        }
    };
    fetch = function() {
        return Zepto.ajax({
            type: "get",
            url: "/kinds",
            data: {
                include: "generators,fields"
            },
            success: function(data) {
                tag.data = data;
                index_records();
                filter_records();
                return tag.update();
            }
        });
    };
});

riot.tag2("kor-entity", '<div class="auth" if="{!authorized}"> <strong>Info</strong> <p> It seems you are not allowed to see this content. Please <a href="{login_url()}">login</a> to the kor installation first. </p> </div> <a href="{url()}" if="{authorized}" target="_blank"> <img if="{data.medium}" riot-src="{image_url()}"> <div if="{!data.medium}"> <h3>{data.display_name}</h3> <em if="{include(\'kind\')}"> {data.kind_name} <span show="{data.subtype}">({data.subtype})</span> </em> </div> </a>', "", "class=\"{'kor-style': opts.korStyle, 'kor': opts.korStyle}\"", function(opts) {
    var tag;
    tag = this;
    tag.authorized = true;
    tag.on("mount", function() {
        var base;
        if (tag.opts.id) {
            base = $("script[kor-url]").attr("kor-url") || "";
            return $.ajax({
                type: "get",
                url: base + "/entities/" + tag.opts.id,
                data: {
                    include: "all"
                },
                dataType: "json",
                beforeSend: function(xhr) {
                    return xhr.withCredentials = true;
                },
                success: function(data) {
                    tag.data = data;
                    return tag.update();
                },
                error: function(request) {
                    tag.data = {};
                    if (request.status === 403) {
                        tag.authorized = false;
                        return tag.update();
                    }
                }
            });
        } else {
            return raise("this widget requires an id");
        }
    });
    tag.login_url = function() {
        var base, return_to;
        base = $("script[kor-url]").attr("kor-url") || "";
        return_to = document.location.href;
        return base + "/login?return_to=" + return_to;
    };
    tag.image_size = function() {
        return tag.opts.korImageSize || "preview";
    };
    tag.image_url = function() {
        var base, size;
        base = $("script[kor-url]").attr("kor-url") || "";
        size = tag.image_size();
        return "" + base + tag.data.medium.url[size];
    };
    tag.include = function(what) {
        var includes;
        includes = (tag.opts.korInclude || "").split(/\s+/);
        return includes.indexOf(what) !== -1;
    };
    tag.url = function() {
        var base;
        base = $("[kor-url]").attr("kor-url") || "";
        return base + "/blaze#/entities/" + tag.data.id;
    };
    tag.human_size = function() {
        var size;
        size = tag.data.medium.file_size / 1024 / 1024;
        return Math.floor(size * 100) / 100;
    };
});

riot.tag2("kor-submit", '<input type="submit" riot-value="{label()}">', "", "", function(opts) {
    var tag;
    tag = this;
    tag.label = function() {
        var base;
        (base = tag.opts).labelKey || (base.labelKey = "verbs.save");
        return wApp.i18n.t(tag.opts.labelKey, {
            capitalize: true
        });
    };
});

riot.tag2("w-app", '<div class="w-content"></div> <w-modal></w-modal> <w-messaging></w-messaging>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.on("mount", function() {
        return wApp.routing.setup();
    });
    wApp.bus.on("routing:path", function(parts) {
        var opts, tagName;
        opts = {};
        tagName = function() {
            switch (parts["hash_path"]) {
              case "/some/path":
                opts["some"] = parts["hash_query"].value;
                return "some-tag";

              default:
                return "some-default-tag";
            }
        }();
        riot.mount(Zepto(".w-content")[0], tagName, opts);
        return window.scrollTo(0, 0);
    });
});

riot.tag2("w-messaging", '<div each="{message in messages}" class="message {\'error\': error(message), \'notice\': notice(message)}"> <i show="{notice(message)}" class="fa fa-warning"></i> <i show="{error(message)}" class="fa fa-info-circle"></i> {message.content} </div>', "", "", function(opts) {
    var ajaxCompleteHandler, self;
    self = this;
    self.on("mount", function() {
        self.messages = [];
        return Zepto(document).on("ajaxComplete", ajaxCompleteHandler);
    });
    self.on("unmount", function() {
        return Zepto(document).off("ajaxComplete", ajaxCompleteHandler);
    });
    wApp.bus.on("message", function(type, message) {
        self.messages.push({
            type: type,
            content: message
        });
        window.setTimeout(self.drop, self.opts.duration || 5e3);
        return self.update();
    });
    ajaxCompleteHandler = function(event, request, options) {
        var contentType, data, e, i, len, message, ref, results, type;
        contentType = request.getResponseHeader("content-type");
        if (contentType.match(/^application\/json/) && request.response) {
            try {
                data = JSON.parse(request.response);
                if (data.messages) {
                    type = request.status >= 200 && request.status < 300 ? "notice" : "error";
                    ref = data.messages;
                    results = [];
                    for (i = 0, len = ref.length; i < len; i++) {
                        message = ref[i];
                        results.push(wApp.bus.trigger("message", type, message));
                    }
                    return results;
                }
            } catch (error) {
                e = error;
            }
        }
    };
    self.drop = function() {
        self.messages.shift();
        return self.update();
    };
    self.error = function(message) {
        return message.type === "error";
    };
    self.notice = function(message) {
        return message.type === "notice";
    };
});

riot.tag2("w-modal", '<div class="receiver" ref="receiver"></div>', "", 'show="{isActive}"', function(opts) {
    var tag;
    tag = this;
    wApp.bus.on("modal", function(tagName, opts) {
        if (opts == null) {
            opts = {};
        }
        opts.modal = tag;
        tag.mountedTag = riot.mount(tag.refs.receiver, tagName, opts)[0];
        tag.isActive = true;
        return tag.update();
    });
    Zepto(document).on("keydown", function(event) {
        if (tag.isActive && event.key === "Escape") {
            return tag.trigger("close");
        }
    });
    tag.on("mount", function() {
        tag.isActive = false;
        tag.mountedTag = null;
        return Zepto(tag.root).on("click", function(event) {
            if (tag.isActive && event.target === tag.root) {
                return tag.trigger("close");
            }
        });
    });
    tag.on("close", function() {
        if (tag.isActive) {
            tag.isActive = false;
            tag.mountedTag.unmount(true);
            return tag.update();
        }
    });
});