<<<<<<< HEAD
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
            for: "htmlFor",
            class: "className",
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
    typeof exports === "object" && typeof module !== "undefined" ? factory(exports) : typeof define === "function" && define.amd ? define([ "exports" ], factory) : factory(global.riot = {});
})(this, function(exports) {
    "use strict";
    function $(selector, ctx) {
        return (ctx || document).querySelector(selector);
    }
    var __TAGS_CACHE = [], __TAG_IMPL = {}, YIELD_TAG = "yield", GLOBAL_MIXIN = "__global_mixin", ATTRS_PREFIX = "riot-", REF_DIRECTIVES = [ "ref", "data-ref" ], IS_DIRECTIVE = "data-is", CONDITIONAL_DIRECTIVE = "if", LOOP_DIRECTIVE = "each", LOOP_NO_REORDER_DIRECTIVE = "no-reorder", SHOW_DIRECTIVE = "show", HIDE_DIRECTIVE = "hide", KEY_DIRECTIVE = "key", RIOT_EVENTS_KEY = "__riot-events__", T_STRING = "string", T_OBJECT = "object", T_UNDEF = "undefined", T_FUNCTION = "function", XLINK_NS = "http://www.w3.org/1999/xlink", SVG_NS = "http://www.w3.org/2000/svg", XLINK_REGEX = /^xlink:(\w+)/, WIN = typeof window === T_UNDEF ? undefined : window, RE_SPECIAL_TAGS = /^(?:t(?:body|head|foot|[rhd])|caption|col(?:group)?|opt(?:ion|group))$/, RE_SPECIAL_TAGS_NO_OPTION = /^(?:t(?:body|head|foot|[rhd])|caption|col(?:group)?)$/, RE_EVENTS_PREFIX = /^on/, RE_HTML_ATTRS = /([-\w]+) ?= ?(?:"([^"]*)|'([^']*)|({[^}]*}))/g, CASE_SENSITIVE_ATTRIBUTES = {
        viewbox: "viewBox",
        preserveaspectratio: "preserveAspectRatio"
    }, RE_BOOL_ATTRS = /^(?:disabled|checked|readonly|required|allowfullscreen|auto(?:focus|play)|compact|controls|default|formnovalidate|hidden|ismap|itemscope|loop|multiple|muted|no(?:resize|shade|validate|wrap)?|open|reversed|seamless|selected|sortable|truespeed|typemustmatch)$/, IE_VERSION = (WIN && WIN.document || {}).documentMode | 0;
    function makeElement(name) {
        return name === "svg" ? document.createElementNS(SVG_NS, name) : document.createElement(name);
    }
    function setAttribute(dom, name, val) {
        var xlink = XLINK_REGEX.exec(name);
        if (xlink && xlink[1]) {
            dom.setAttributeNS(XLINK_NS, xlink[1], val);
        } else {
            dom.setAttribute(name, val);
        }
    }
    var styleNode;
    var cssTextProp;
    var byName = {};
    var needsInject = false;
    if (WIN) {
        styleNode = function() {
            var newNode = makeElement("style");
            var userNode = $("style[type=riot]");
            setAttribute(newNode, "type", "text/css");
            if (userNode) {
                if (userNode.id) {
                    newNode.id = userNode.id;
                }
                userNode.parentNode.replaceChild(newNode, userNode);
            } else {
                document.head.appendChild(newNode);
            }
            return newNode;
        }();
        cssTextProp = styleNode.styleSheet;
    }
    var styleManager = {
        styleNode: styleNode,
        add: function add(css, name) {
            byName[name] = css;
            needsInject = true;
        },
        inject: function inject() {
            if (!WIN || !needsInject) {
                return;
            }
            needsInject = false;
            var style = Object.keys(byName).map(function(k) {
                return byName[k];
            }).join("\n");
            if (cssTextProp) {
                cssTextProp.cssText = style;
            } else {
                styleNode.innerHTML = style;
            }
        },
        remove: function remove(name) {
            delete byName[name];
            needsInject = true;
        }
    };
    var skipRegex = function() {
        var beforeReChars = "[{(,;:?=|&!^~>%*/";
        var beforeReWords = [ "case", "default", "do", "else", "in", "instanceof", "prefix", "return", "typeof", "void", "yield" ];
        var wordsLastChar = beforeReWords.reduce(function(s, w) {
            return s + w.slice(-1);
        }, "");
        var RE_REGEX = /^\/(?=[^*>/])[^[/\\]*(?:(?:\\.|\[(?:\\.|[^\]\\]*)*\])[^[\\/]*)*?\/[gimuy]*/;
        var RE_VN_CHAR = /[$\w]/;
        function prev(code, pos) {
            while (--pos >= 0 && /\s/.test(code[pos])) {}
            return pos;
        }
        function _skipRegex(code, start) {
            var re = /.*/g;
            var pos = re.lastIndex = start++;
            var match = re.exec(code)[0].match(RE_REGEX);
            if (match) {
                var next = pos + match[0].length;
                pos = prev(code, pos);
                var c = code[pos];
                if (pos < 0 || ~beforeReChars.indexOf(c)) {
                    return next;
                }
                if (c === ".") {
                    if (code[pos - 1] === ".") {
                        start = next;
                    }
                } else if (c === "+" || c === "-") {
                    if (code[--pos] !== c || (pos = prev(code, pos)) < 0 || !RE_VN_CHAR.test(code[pos])) {
                        start = next;
                    }
                } else if (~wordsLastChar.indexOf(c)) {
                    var end = pos + 1;
                    while (--pos >= 0 && RE_VN_CHAR.test(code[pos])) {}
                    if (~beforeReWords.indexOf(code.slice(pos + 1, end))) {
                        start = next;
                    }
                }
            }
            return start;
        }
        return _skipRegex;
    }();
    var brackets = function(UNDEF) {
        var REGLOB = "g", R_MLCOMMS = /\/\*[^*]*\*+(?:[^*\/][^*]*\*+)*\//g, R_STRINGS = /"[^"\\]*(?:\\[\S\s][^"\\]*)*"|'[^'\\]*(?:\\[\S\s][^'\\]*)*'|`[^`\\]*(?:\\[\S\s][^`\\]*)*`/g, S_QBLOCKS = R_STRINGS.source + "|" + /(?:\breturn\s+|(?:[$\w\)\]]|\+\+|--)\s*(\/)(?![*\/]))/.source + "|" + /\/(?=[^*\/])[^[\/\\]*(?:(?:\[(?:\\.|[^\]\\]*)*\]|\\.)[^[\/\\]*)*?([^<]\/)[gim]*/.source, UNSUPPORTED = RegExp("[\\" + "x00-\\x1F<>a-zA-Z0-9'\",;\\\\]"), NEED_ESCAPE = /(?=[[\]()*+?.^$|])/g, S_QBLOCK2 = R_STRINGS.source + "|" + /(\/)(?![*\/])/.source, FINDBRACES = {
            "(": RegExp("([()])|" + S_QBLOCK2, REGLOB),
            "[": RegExp("([[\\]])|" + S_QBLOCK2, REGLOB),
            "{": RegExp("([{}])|" + S_QBLOCK2, REGLOB)
        }, DEFAULT = "{ }";
        var _pairs = [ "{", "}", "{", "}", /{[^}]*}/, /\\([{}])/g, /\\({)|{/g, RegExp("\\\\(})|([[({])|(})|" + S_QBLOCK2, REGLOB), DEFAULT, /^\s*{\^?\s*([$\w]+)(?:\s*,\s*(\S+))?\s+in\s+(\S.*)\s*}/, /(^|[^\\]){=[\S\s]*?}/ ];
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
            arr[7] = RegExp("\\\\(" + arr[3] + ")|([[({])|(" + arr[3] + ")|" + S_QBLOCK2, REGLOB);
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
            var qblocks = [];
            var prevStr = "";
            var mark, lastIndex;
            isexpr = start = re.lastIndex = 0;
            while (match = re.exec(str)) {
                lastIndex = re.lastIndex;
                pos = match.index;
                if (isexpr) {
                    if (match[2]) {
                        var ch = match[2];
                        var rech = FINDBRACES[ch];
                        var ix = 1;
                        rech.lastIndex = lastIndex;
                        while (match = rech.exec(str)) {
                            if (match[1]) {
                                if (match[1] === ch) {
                                    ++ix;
                                } else if (!--ix) {
                                    break;
                                }
                            } else {
                                rech.lastIndex = pushQBlock(match.index, rech.lastIndex, match[2]);
                            }
                        }
                        re.lastIndex = ix ? str.length : rech.lastIndex;
                        continue;
                    }
                    if (!match[3]) {
                        re.lastIndex = pushQBlock(pos, lastIndex, match[4]);
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
            parts.qblocks = qblocks;
            return parts;
            function unescapeStr(s) {
                if (prevStr) {
                    s = prevStr + s;
                    prevStr = "";
                }
                if (tmpl || isexpr) {
                    parts.push(s && s.replace(_bp[5], "$1"));
                } else {
                    parts.push(s);
                }
            }
            function pushQBlock(_pos, _lastIndex, slash) {
                if (slash) {
                    _lastIndex = skipRegex(str, _pos);
                }
                if (tmpl && _lastIndex > _pos + 2) {
                    mark = "⁗" + qblocks.length + "~";
                    qblocks.push(str.slice(_pos, _lastIndex));
                    prevStr += str.slice(start, _pos) + mark;
                    start = _lastIndex;
                }
                return _lastIndex;
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
        _brackets.skipRegex = skipRegex;
        _brackets.R_STRINGS = R_STRINGS;
        _brackets.R_MLCOMMS = R_MLCOMMS;
        _brackets.S_QBLOCKS = S_QBLOCKS;
        _brackets.S_QBLOCK2 = S_QBLOCK2;
        return _brackets;
    }();
    var tmpl = function() {
        var _cache = {};
        function _tmpl(str, data) {
            if (!str) {
                return str;
            }
            return (_cache[str] || (_cache[str] = _create(str))).call(data, _logErr.bind({
                data: data,
                tmpl: str
            }));
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
                console.error(err.message);
                console.log("<%s> %s", err.riotData.tagName || "Unknown tag", this.tmpl);
                console.log(this.data);
            }
        }
        function _create(str) {
            var expr = _getTmpl(str);
            if (expr.slice(0, 11) !== "try{return ") {
                expr = "return " + expr;
            }
            return new Function("E", expr + ";");
        }
        var RE_DQUOTE = /\u2057/g;
        var RE_QBMARK = /\u2057(\d+)~/g;
        function _getTmpl(str) {
            var parts = brackets.split(str.replace(RE_DQUOTE, '"'), 1);
            var qstr = parts.qblocks;
            var expr;
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
            if (qstr.length) {
                expr = expr.replace(RE_QBMARK, function(_, pos) {
                    return qstr[pos].replace(/\r/g, "\\r").replace(/\n/g, "\\n");
                });
            }
            return expr;
        }
        var RE_CSNAME = /^(?:(-?[_A-Za-z\xA0-\xFF][-\w\xA0-\xFF]*)|\u2057(\d+)~):/;
        var RE_BREND = {
            "(": /[()]/g,
            "[": /[[\]]/g,
            "{": /[{}]/g
        };
        function _parseExpr(expr, asText, qstr) {
            expr = expr.replace(/\s+/g, " ").trim().replace(/\ ?([[\({},?\.:])\ ?/g, "$1");
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
        _tmpl.version = brackets.version = "v3.0.8";
        return _tmpl;
    }();
    var observable = function(el) {
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
    function getPropDescriptor(o, k) {
        return Object.getOwnPropertyDescriptor(o, k);
    }
    function isUndefined(value) {
        return typeof value === T_UNDEF;
    }
    function isWritable(obj, key) {
        var descriptor = getPropDescriptor(obj, key);
        return isUndefined(obj[key]) || descriptor && descriptor.writable;
    }
    function extend(src) {
        var obj;
        var i = 1;
        var args = arguments;
        var l = args.length;
        for (;i < l; i++) {
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
    function create(src) {
        return Object.create(src);
    }
    var settings = extend(create(brackets.settings), {
        skipAnonymousTags: true,
        autoUpdate: true
    });
    function $$(selector, ctx) {
        return [].slice.call((ctx || document).querySelectorAll(selector));
    }
    function createDOMPlaceholder() {
        return document.createTextNode("");
    }
    function toggleVisibility(dom, show) {
        dom.style.display = show ? "" : "none";
        dom.hidden = show ? false : true;
    }
    function getAttribute(dom, name) {
        return dom.getAttribute(name);
    }
    function removeAttribute(dom, name) {
        dom.removeAttribute(name);
    }
    function setInnerHTML(container, html, isSvg) {
        if (isSvg) {
            var node = container.ownerDocument.importNode(new DOMParser().parseFromString('<svg xmlns="' + SVG_NS + '">' + html + "</svg>", "application/xml").documentElement, true);
            container.appendChild(node);
        } else {
            container.innerHTML = html;
        }
    }
    function walkAttributes(html, fn) {
        if (!html) {
            return;
        }
        var m;
        while (m = RE_HTML_ATTRS.exec(html)) {
            fn(m[1].toLowerCase(), m[2] || m[3] || m[4]);
        }
    }
    function createFragment() {
        return document.createDocumentFragment();
    }
    function safeInsert(root, curr, next) {
        root.insertBefore(curr, next.parentNode && next);
    }
    function styleObjectToString(style) {
        return Object.keys(style).reduce(function(acc, prop) {
            return acc + " " + prop + ": " + style[prop] + ";";
        }, "");
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
        createDOMPlaceholder: createDOMPlaceholder,
        mkEl: makeElement,
        setAttr: setAttribute,
        toggleVisibility: toggleVisibility,
        getAttr: getAttribute,
        remAttr: removeAttribute,
        setInnerHTML: setInnerHTML,
        walkAttrs: walkAttributes,
        createFrag: createFragment,
        safeInsert: safeInsert,
        styleObjectToString: styleObjectToString,
        walkNodes: walkNodes
    });
    function isNil(value) {
        return isUndefined(value) || value === null;
    }
    function isBlank(value) {
        return isNil(value) || value === "";
    }
    function isFunction(value) {
        return typeof value === T_FUNCTION;
    }
    function isObject(value) {
        return value && typeof value === T_OBJECT;
    }
    function isSvg(el) {
        var owner = el.ownerSVGElement;
        return !!owner || owner === null;
    }
    function isArray(value) {
        return Array.isArray(value) || value instanceof Array;
    }
    function isBoolAttr(value) {
        return RE_BOOL_ATTRS.test(value);
    }
    function isString(value) {
        return typeof value === T_STRING;
    }
    var check = Object.freeze({
        isBlank: isBlank,
        isFunction: isFunction,
        isObject: isObject,
        isSvg: isSvg,
        isWritable: isWritable,
        isArray: isArray,
        isBoolAttr: isBoolAttr,
        isNil: isNil,
        isString: isString,
        isUndefined: isUndefined
    });
    function contains(array, item) {
        return array.indexOf(item) !== -1;
    }
    function each(list, fn) {
        var len = list ? list.length : 0;
        var i = 0;
        for (;i < len; i++) {
            fn(list[i], i);
        }
        return list;
    }
    function startsWith(str, value) {
        return str.slice(0, value.length) === value;
    }
    var uid = function uid() {
        var i = -1;
        return function() {
            return ++i;
        };
    }();
    function define(el, key, value, options) {
        Object.defineProperty(el, key, extend({
            value: value,
            enumerable: false,
            writable: false,
            configurable: true
        }, options));
        return el;
    }
    function toCamel(str) {
        return str.replace(/-(\w)/g, function(_, c) {
            return c.toUpperCase();
        });
    }
    function warn(message) {
        if (console && console.warn) {
            console.warn(message);
        }
    }
    var misc = Object.freeze({
        contains: contains,
        each: each,
        getPropDescriptor: getPropDescriptor,
        startsWith: startsWith,
        uid: uid,
        defineProperty: define,
        objectCreate: create,
        extend: extend,
        toCamel: toCamel,
        warn: warn
    });
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
    function get(dom) {
        return dom.tagName && __TAG_IMPL[getAttribute(dom, IS_DIRECTIVE) || getAttribute(dom, IS_DIRECTIVE) || dom.tagName.toLowerCase()];
    }
    function getName(dom, skipDataIs) {
        var child = get(dom);
        var namedTag = !skipDataIs && getAttribute(dom, IS_DIRECTIVE);
        return namedTag && !tmpl.hasExpr(namedTag) ? namedTag : child ? child.name : dom.tagName.toLowerCase();
    }
    function inheritParentProps() {
        if (this.parent) {
            return extend(create(this), this.parent);
        }
        return this;
    }
    var reHasYield = /<yield\b/i, reYieldAll = /<yield\s*(?:\/>|>([\S\s]*?)<\/yield\s*>|>)/gi, reYieldSrc = /<yield\s+to=['"]([^'">]*)['"]\s*>([\S\s]*?)<\/yield\s*>/gi, reYieldDest = /<yield\s+from=['"]?([-\w]+)['"]?\s*(?:\/>|>([\S\s]*?)<\/yield\s*>)/gi, rootEls = {
        tr: "tbody",
        th: "tr",
        td: "tr",
        col: "colgroup"
    }, tblTags = IE_VERSION && IE_VERSION < 10 ? RE_SPECIAL_TAGS : RE_SPECIAL_TAGS_NO_OPTION, GENERIC = "div", SVG = "svg";
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
    function mkdom(tmpl, html, isSvg) {
        var match = tmpl && tmpl.match(/^\s*<([-\w]+)/);
        var tagName = match && match[1].toLowerCase();
        var el = makeElement(isSvg ? SVG : GENERIC);
        tmpl = replaceYield(tmpl, html);
        if (tblTags.test(tagName)) {
            el = specialTags(el, tmpl, tagName);
        } else {
            setInnerHTML(el, tmpl, isSvg);
        }
        return el;
    }
    var EVENT_ATTR_RE = /^on/;
    function isEventAttribute(attribute) {
        return EVENT_ATTR_RE.test(attribute);
    }
    function getImmediateCustomParent(tag) {
        var ptag = tag;
        while (ptag.__.isAnonymous) {
            if (!ptag.parent) {
                break;
            }
            ptag = ptag.parent;
        }
        return ptag;
    }
    function handleEvent(dom, handler, e) {
        var ptag = this.__.parent;
        var item = this.__.item;
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
        if (!settings.autoUpdate) {
            return;
        }
        if (!e.preventUpdate) {
            var p = getImmediateCustomParent(this);
            if (p.isMounted) {
                p.update();
            }
        }
    }
    function setEventHandler(name, handler, dom, tag) {
        var eventName;
        var cb = handleEvent.bind(tag, dom, handler);
        dom[name] = null;
        eventName = name.replace(RE_EVENTS_PREFIX, "");
        if (!contains(tag.__.listeners, dom)) {
            tag.__.listeners.push(dom);
        }
        if (!dom[RIOT_EVENTS_KEY]) {
            dom[RIOT_EVENTS_KEY] = {};
        }
        if (dom[RIOT_EVENTS_KEY][name]) {
            dom.removeEventListener(eventName, dom[RIOT_EVENTS_KEY][name]);
        }
        dom[RIOT_EVENTS_KEY][name] = cb;
        dom.addEventListener(eventName, cb, false);
    }
    function initChild(child, opts, innerHTML, parent) {
        var tag = createTag(child, opts, innerHTML);
        var tagName = opts.tagName || getName(opts.root, true);
        var ptag = getImmediateCustomParent(parent);
        define(tag, "parent", ptag);
        tag.__.parent = parent;
        arrayishAdd(ptag.tags, tagName, tag);
        if (ptag !== parent) {
            arrayishAdd(parent.tags, tagName, tag);
        }
        return tag;
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
        } else if (obj[key] === value) {
            delete obj[key];
        }
    }
    function makeVirtual(src, target) {
        var this$1 = this;
        var head = createDOMPlaceholder();
        var tail = createDOMPlaceholder();
        var frag = createFragment();
        var sib;
        var el;
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
    function makeReplaceVirtual(tag, ref) {
        var frag = createFragment();
        makeVirtual.call(tag, frag);
        ref.parentNode.replaceChild(frag, ref);
    }
    function updateDataIs(expr, parent, tagName) {
        var tag = expr.tag || expr.dom._tag;
        var ref;
        var ref$1 = tag ? tag.__ : {};
        var head = ref$1.head;
        var isVirtual = expr.dom.tagName === "VIRTUAL";
        if (tag && expr.tagName === tagName) {
            tag.update();
            return;
        }
        if (tag) {
            if (isVirtual) {
                ref = createDOMPlaceholder();
                head.parentNode.insertBefore(ref, head);
            }
            tag.unmount(true);
        }
        if (!isString(tagName)) {
            return;
        }
        expr.impl = __TAG_IMPL[tagName];
        if (!expr.impl) {
            return;
        }
        expr.tag = tag = initChild(expr.impl, {
            root: expr.dom,
            parent: parent,
            tagName: tagName
        }, expr.dom.innerHTML, parent);
        each(expr.attrs, function(a) {
            return setAttribute(tag.root, a.name, a.value);
        });
        expr.tagName = tagName;
        tag.mount();
        if (isVirtual) {
            makeReplaceVirtual(tag, ref || tag.root);
        }
        parent.__.onUnmount = function() {
            var delName = tag.opts.dataIs;
            arrayishRemove(tag.parent.tags, delName, tag);
            arrayishRemove(tag.__.parent.tags, delName, tag);
            tag.unmount();
        };
    }
    function normalizeAttrName(attrName) {
        if (!attrName) {
            return null;
        }
        attrName = attrName.replace(ATTRS_PREFIX, "");
        if (CASE_SENSITIVE_ATTRIBUTES[attrName]) {
            attrName = CASE_SENSITIVE_ATTRIBUTES[attrName];
        }
        return attrName;
    }
    function updateExpression(expr) {
        if (this.root && getAttribute(this.root, "virtualized")) {
            return;
        }
        var dom = expr.dom;
        var attrName = normalizeAttrName(expr.attr);
        var isToggle = contains([ SHOW_DIRECTIVE, HIDE_DIRECTIVE ], attrName);
        var isVirtual = expr.root && expr.root.tagName === "VIRTUAL";
        var ref = this.__;
        var isAnonymous = ref.isAnonymous;
        var parent = dom && (expr.parent || dom.parentNode);
        var isStyleAttr = attrName === "style";
        var isClassAttr = attrName === "class";
        var value;
        if (expr._riot_id) {
            if (expr.__.wasCreated) {
                expr.update();
            } else {
                expr.mount();
                if (isVirtual) {
                    makeReplaceVirtual(expr, expr.root);
                }
            }
            return;
        }
        if (expr.update) {
            return expr.update();
        }
        var context = isToggle && !isAnonymous ? inheritParentProps.call(this) : this;
        value = tmpl(expr.expr, context);
        var hasValue = !isBlank(value);
        var isObj = isObject(value);
        if (isObj) {
            if (isClassAttr) {
                value = tmpl(JSON.stringify(value), this);
            } else if (isStyleAttr) {
                value = styleObjectToString(value);
            }
        }
        if (expr.attr && (!expr.wasParsedOnce || !hasValue || value === false)) {
            removeAttribute(dom, getAttribute(dom, expr.attr) ? expr.attr : attrName);
        }
        if (expr.bool) {
            value = value ? attrName : false;
        }
        if (expr.isRtag) {
            return updateDataIs(expr, this, value);
        }
        if (expr.wasParsedOnce && expr.value === value) {
            return;
        }
        expr.value = value;
        expr.wasParsedOnce = true;
        if (isObj && !isClassAttr && !isStyleAttr && !isToggle) {
            return;
        }
        if (!hasValue) {
            value = "";
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
        switch (true) {
          case isFunction(value):
            if (isEventAttribute(attrName)) {
                setEventHandler(attrName, value, dom, this);
            }
            break;

          case isToggle:
            toggleVisibility(dom, attrName === HIDE_DIRECTIVE ? !value : value);
            break;

          default:
            if (expr.bool) {
                dom[attrName] = value;
            }
            if (attrName === "value" && dom.value !== value) {
                dom.value = value;
            } else if (hasValue && value !== false) {
                setAttribute(dom, attrName, value);
            }
            if (isStyleAttr && dom.hidden) {
                toggleVisibility(dom, false);
            }
        }
    }
    function update(expressions) {
        each(expressions, updateExpression.bind(this));
    }
    function updateOpts(isLoop, parent, isAnonymous, opts, instAttrs) {
        if (isLoop && isAnonymous) {
            return;
        }
        var ctx = isLoop ? inheritParentProps.call(this) : parent || this;
        each(instAttrs, function(attr) {
            if (attr.expr) {
                updateExpression.call(ctx, attr.expr);
            }
            opts[toCamel(attr.name).replace(ATTRS_PREFIX, "")] = attr.expr ? attr.expr.value : attr.value;
        });
    }
    function componentUpdate(tag, data, expressions) {
        var __ = tag.__;
        var nextOpts = {};
        var canTrigger = tag.isMounted && !__.skipAnonymous;
        if (__.isAnonymous && __.parent) {
            extend(tag, __.parent);
        }
        extend(tag, data);
        updateOpts.apply(tag, [ __.isLoop, __.parent, __.isAnonymous, nextOpts, __.instAttrs ]);
        if (canTrigger && tag.isMounted && isFunction(tag.shouldUpdate) && !tag.shouldUpdate(data, nextOpts)) {
            return tag;
        }
        extend(tag.opts, nextOpts);
        if (canTrigger) {
            tag.trigger("update", data);
        }
        update.call(tag, expressions);
        if (canTrigger) {
            tag.trigger("updated");
        }
        return tag;
    }
    function query(tags) {
        if (!tags) {
            var keys = Object.keys(__TAG_IMPL);
            return keys + query(keys);
        }
        return tags.filter(function(t) {
            return !/[^-\w]/.test(t);
        }).reduce(function(list, t) {
            var name = t.trim().toLowerCase();
            return list + ",[" + IS_DIRECTIVE + '="' + name + '"]';
        }, "");
    }
    function Tag(el, opts) {
        var ref = this;
        var name = ref.name;
        var tmpl = ref.tmpl;
        var css = ref.css;
        var attrs = ref.attrs;
        var onCreate = ref.onCreate;
        if (!__TAG_IMPL[name]) {
            tag(name, tmpl, css, attrs, onCreate);
            __TAG_IMPL[name].class = this.constructor;
        }
        mount$1(el, name, opts, this);
        if (css) {
            styleManager.inject();
        }
        return this;
    }
    function tag(name, tmpl, css, attrs, fn) {
        if (isFunction(attrs)) {
            fn = attrs;
            if (/^[\w-]+\s?=/.test(css)) {
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
                styleManager.add(css, name);
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
    function tag2(name, tmpl, css, attrs, fn) {
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
    function mount(selector, tagName, opts) {
        var tags = [];
        var elem, allTags;
        function pushTagsTo(root) {
            if (root.tagName) {
                var riotTag = getAttribute(root, IS_DIRECTIVE), tag;
                if (tagName && riotTag !== tagName) {
                    riotTag = tagName;
                    setAttribute(root, IS_DIRECTIVE, tagName);
                }
                tag = mount$1(root, riotTag || root.tagName.toLowerCase(), opts);
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
        if (isString(selector)) {
            selector = selector === "*" ? allTags = query() : selector + query(selector.split(/, */));
            elem = selector ? $$(selector) : [];
        } else {
            elem = selector;
        }
        if (tagName === "*") {
            tagName = allTags || query();
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
    function mixin(name, mix, g) {
        if (isObject(name)) {
            mixin("__" + mixins_id++ + "__", name, true);
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
    function unregister(name) {
        styleManager.remove(name);
        return delete __TAG_IMPL[name];
    }
    var version = "v3.11.1";
    var core = Object.freeze({
        Tag: Tag,
        tag: tag,
        tag2: tag2,
        mount: mount,
        mixin: mixin,
        update: update$1,
        unregister: unregister,
        version: version
    });
    function componentMixin(tag$$1) {
        var mixins = [], len = arguments.length - 1;
        while (len-- > 0) mixins[len] = arguments[len + 1];
        each(mixins, function(mix) {
            var instance;
            var obj;
            var props = [];
            var propsBlacklist = [ "init", "__proto__" ];
            mix = isString(mix) ? mixin(mix) : mix;
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
                    var descriptor = getPropDescriptor(instance, key) || getPropDescriptor(proto, key);
                    var hasGetterSetter = descriptor && (descriptor.get || descriptor.set);
                    if (!tag$$1.hasOwnProperty(key) && hasGetterSetter) {
                        Object.defineProperty(tag$$1, key, descriptor);
                    } else {
                        tag$$1[key] = isFunction(instance[key]) ? instance[key].bind(tag$$1) : instance[key];
                    }
                }
            });
            if (instance.init) {
                instance.init.bind(tag$$1)(tag$$1.opts);
            }
        });
        return tag$$1;
    }
    function moveChild(tagName, newPos) {
        var parent = this.parent;
        var tags;
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
    function moveVirtual(src, target) {
        var this$1 = this;
        var el = this.__.head;
        var sib;
        var frag = createFragment();
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
    function mkitem(expr, key, val) {
        var item = {};
        item[expr.key] = key;
        if (expr.pos) {
            item[expr.pos] = val;
        }
        return item;
    }
    function unmountRedundant(items, tags, filteredItemsCount) {
        var i = tags.length;
        var j = items.length - filteredItemsCount;
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
            moveChild.apply(this$1.tags[tagName], [ tagName, i ]);
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
    function getItemId(keyAttr, originalItem, keyedItem, hasKeyAttrExpr) {
        if (keyAttr) {
            return hasKeyAttrExpr ? tmpl(keyAttr, keyedItem) : originalItem[keyAttr];
        }
        return originalItem;
    }
    function _each(dom, parent, expr) {
        var mustReorder = typeof getAttribute(dom, LOOP_NO_REORDER_DIRECTIVE) !== T_STRING || removeAttribute(dom, LOOP_NO_REORDER_DIRECTIVE);
        var keyAttr = getAttribute(dom, KEY_DIRECTIVE);
        var hasKeyAttrExpr = keyAttr ? tmpl.hasExpr(keyAttr) : false;
        var tagName = getName(dom);
        var impl = __TAG_IMPL[tagName];
        var parentNode = dom.parentNode;
        var placeholder = createDOMPlaceholder();
        var child = get(dom);
        var ifExpr = getAttribute(dom, CONDITIONAL_DIRECTIVE);
        var tags = [];
        var isLoop = true;
        var innerHTML = dom.innerHTML;
        var isAnonymous = !__TAG_IMPL[tagName];
        var isVirtual = dom.tagName === "VIRTUAL";
        var oldItems = [];
        removeAttribute(dom, LOOP_DIRECTIVE);
        removeAttribute(dom, KEY_DIRECTIVE);
        expr = tmpl.loopKeys(expr);
        expr.isLoop = true;
        if (ifExpr) {
            removeAttribute(dom, CONDITIONAL_DIRECTIVE);
        }
        parentNode.insertBefore(placeholder, dom);
        parentNode.removeChild(dom);
        expr.update = function updateEach() {
            expr.value = tmpl(expr.val, parent);
            var items = expr.value;
            var frag = createFragment();
            var isObject = !isArray(items) && !isString(items);
            var root = placeholder.parentNode;
            var tmpItems = [];
            var hasKeys = isObject && !!items;
            if (!root) {
                return;
            }
            if (isObject) {
                items = items ? Object.keys(items).map(function(key) {
                    return mkitem(expr, items[key], key);
                }) : [];
            }
            var filteredItemsCount = 0;
            each(items, function(_item, index) {
                var i = index - filteredItemsCount;
                var item = !hasKeys && expr.key ? mkitem(expr, _item, index) : _item;
                if (ifExpr && !tmpl(ifExpr, extend(create(parent), item))) {
                    filteredItemsCount++;
                    return;
                }
                var itemId = getItemId(keyAttr, _item, item, hasKeyAttrExpr);
                var doReorder = !isObject && mustReorder && typeof _item === T_OBJECT || keyAttr;
                var oldPos = oldItems.indexOf(itemId);
                var isNew = oldPos === -1;
                var pos = !isNew && doReorder ? oldPos : i;
                var tag = tags[pos];
                var mustAppend = i >= oldItems.length;
                var mustCreate = doReorder && isNew || !doReorder && !tag || !tags[i];
                if (mustCreate) {
                    tag = createTag(impl, {
                        parent: parent,
                        isLoop: isLoop,
                        isAnonymous: isAnonymous,
                        tagName: tagName,
                        root: dom.cloneNode(isAnonymous),
                        item: item,
                        index: i
                    }, innerHTML);
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
                    if (keyAttr || contains(items, oldItems[pos])) {
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
                extend(tag.__, {
                    item: item,
                    index: i,
                    parent: parent
                });
                tmpItems[i] = itemId;
                if (!mustCreate) {
                    tag.update(item);
                }
            });
            unmountRedundant(items, tags, filteredItemsCount);
            oldItems = tmpItems.slice();
            root.insertBefore(frag, placeholder);
        };
        expr.unmount = function() {
            each(tags, function(t) {
                t.unmount();
            });
        };
        return expr;
    }
    var RefExpr = {
        init: function init(dom, parent, attrName, attrValue) {
            this.dom = dom;
            this.attr = attrName;
            this.rawValue = attrValue;
            this.parent = parent;
            this.hasExp = tmpl.hasExpr(attrValue);
            return this;
        },
        update: function update() {
            var old = this.value;
            var customParent = this.parent && getImmediateCustomParent(this.parent);
            var tagOrDom = this.dom.__ref || this.tag || this.dom;
            this.value = this.hasExp ? tmpl(this.rawValue, this.parent) : this.rawValue;
            if (!isBlank(old) && customParent) {
                arrayishRemove(customParent.refs, old, tagOrDom);
            }
            if (!isBlank(this.value) && isString(this.value)) {
                if (customParent) {
                    arrayishAdd(customParent.refs, this.value, tagOrDom, null, this.parent.__.index);
                }
                if (this.value !== old) {
                    setAttribute(this.dom, this.attr, this.value);
                }
            } else {
                removeAttribute(this.dom, this.attr);
            }
            if (!this.dom.__ref) {
                this.dom.__ref = tagOrDom;
            }
        },
        unmount: function unmount() {
            var tagOrDom = this.tag || this.dom;
            var customParent = this.parent && getImmediateCustomParent(this.parent);
            if (!isBlank(this.value) && customParent) {
                arrayishRemove(customParent.refs, this.value, tagOrDom);
            }
        }
    };
    function createRefDirective(dom, tag, attrName, attrValue) {
        return create(RefExpr).init(dom, tag, attrName, attrValue);
    }
    function unmountAll(expressions) {
        each(expressions, function(expr) {
            if (expr.unmount) {
                expr.unmount(true);
            } else if (expr.tagName) {
                expr.tag.unmount(true);
            } else if (expr.unmount) {
                expr.unmount();
            }
        });
    }
    var IfExpr = {
        init: function init(dom, tag, expr) {
            removeAttribute(dom, CONDITIONAL_DIRECTIVE);
            extend(this, {
                tag: tag,
                expr: expr,
                stub: createDOMPlaceholder(),
                pristine: dom
            });
            var p = dom.parentNode;
            p.insertBefore(this.stub, dom);
            p.removeChild(dom);
            return this;
        },
        update: function update$$1() {
            this.value = tmpl(this.expr, this.tag);
            if (!this.stub.parentNode) {
                return;
            }
            if (this.value && !this.current) {
                this.current = this.pristine.cloneNode(true);
                this.stub.parentNode.insertBefore(this.current, this.stub);
                this.expressions = parseExpressions.apply(this.tag, [ this.current, true ]);
            } else if (!this.value && this.current) {
                this.unmount();
                this.current = null;
                this.expressions = [];
            }
            if (this.value) {
                update.call(this.tag, this.expressions);
            }
        },
        unmount: function unmount() {
            if (this.current) {
                if (this.current._tag) {
                    this.current._tag.unmount();
                } else if (this.current.parentNode) {
                    this.current.parentNode.removeChild(this.current);
                }
            }
            unmountAll(this.expressions || []);
        }
    };
    function createIfDirective(dom, tag, attr) {
        return create(IfExpr).init(dom, tag, attr);
    }
    function parseExpressions(root, mustIncludeRoot) {
        var this$1 = this;
        var expressions = [];
        walkNodes(root, function(dom) {
            var type = dom.nodeType;
            var attr;
            var tagImpl;
            if (!mustIncludeRoot && dom === root) {
                return;
            }
            if (type === 3 && dom.parentNode.tagName !== "STYLE" && tmpl.hasExpr(dom.nodeValue)) {
                expressions.push({
                    dom: dom,
                    expr: dom.nodeValue
                });
            }
            if (type !== 1) {
                return;
            }
            var isVirtual = dom.tagName === "VIRTUAL";
            if (attr = getAttribute(dom, LOOP_DIRECTIVE)) {
                if (isVirtual) {
                    setAttribute(dom, "loopVirtual", true);
                }
                expressions.push(_each(dom, this$1, attr));
                return false;
            }
            if (attr = getAttribute(dom, CONDITIONAL_DIRECTIVE)) {
                expressions.push(createIfDirective(dom, this$1, attr));
                return false;
            }
            if (attr = getAttribute(dom, IS_DIRECTIVE)) {
                if (tmpl.hasExpr(attr)) {
                    expressions.push({
                        isRtag: true,
                        expr: attr,
                        dom: dom,
                        attrs: [].slice.call(dom.attributes)
                    });
                    return false;
                }
            }
            tagImpl = get(dom);
            if (isVirtual) {
                if (getAttribute(dom, "virtualized")) {
                    dom.parentElement.removeChild(dom);
                }
                if (!tagImpl && !getAttribute(dom, "virtualized") && !getAttribute(dom, "loopVirtual")) {
                    tagImpl = {
                        tmpl: dom.outerHTML
                    };
                }
            }
            if (tagImpl && (dom !== root || mustIncludeRoot)) {
                var hasIsDirective = getAttribute(dom, IS_DIRECTIVE);
                if (isVirtual && !hasIsDirective) {
                    setAttribute(dom, "virtualized", true);
                    var tag = createTag({
                        tmpl: dom.outerHTML
                    }, {
                        root: dom,
                        parent: this$1
                    }, dom.innerHTML);
                    expressions.push(tag);
                } else {
                    if (hasIsDirective && isVirtual) {
                        warn("Virtual tags shouldn't be used together with the \"" + IS_DIRECTIVE + '" attribute - https://github.com/riot/riot/issues/2511');
                    }
                    expressions.push(initChild(tagImpl, {
                        root: dom,
                        parent: this$1
                    }, dom.innerHTML, this$1));
                    return false;
                }
            }
            parseAttributes.apply(this$1, [ dom, dom.attributes, function(attr, expr) {
                if (!expr) {
                    return;
                }
                expressions.push(expr);
            } ]);
        });
        return expressions;
    }
    function parseAttributes(dom, attrs, fn) {
        var this$1 = this;
        each(attrs, function(attr) {
            if (!attr) {
                return false;
            }
            var name = attr.name;
            var bool = isBoolAttr(name);
            var expr;
            if (contains(REF_DIRECTIVES, name) && dom.tagName.toLowerCase() !== YIELD_TAG) {
                expr = createRefDirective(dom, this$1, name, attr.value);
            } else if (tmpl.hasExpr(attr.value)) {
                expr = {
                    dom: dom,
                    expr: attr.value,
                    attr: name,
                    bool: bool
                };
            }
            fn(attr, expr);
        });
    }
    function setMountState(value) {
        var ref = this.__;
        var isAnonymous = ref.isAnonymous;
        define(this, "isMounted", value);
        if (!isAnonymous) {
            if (value) {
                this.trigger("mount");
            } else {
                this.trigger("unmount");
                this.off("*");
                this.__.wasCreated = false;
            }
        }
    }
    function componentMount(tag$$1, dom, expressions, opts) {
        var __ = tag$$1.__;
        var root = __.root;
        root._tag = tag$$1;
        parseAttributes.apply(__.parent, [ root, root.attributes, function(attr, expr) {
            if (!__.isAnonymous && RefExpr.isPrototypeOf(expr)) {
                expr.tag = tag$$1;
            }
            attr.expr = expr;
            __.instAttrs.push(attr);
        } ]);
        walkAttributes(__.impl.attrs, function(k, v) {
            __.implAttrs.push({
                name: k,
                value: v
            });
        });
        parseAttributes.apply(tag$$1, [ root, __.implAttrs, function(attr, expr) {
            if (expr) {
                expressions.push(expr);
            } else {
                setAttribute(root, attr.name, attr.value);
            }
        } ]);
        updateOpts.apply(tag$$1, [ __.isLoop, __.parent, __.isAnonymous, opts, __.instAttrs ]);
        var globalMixin = mixin(GLOBAL_MIXIN);
        if (globalMixin && !__.skipAnonymous) {
            for (var i in globalMixin) {
                if (globalMixin.hasOwnProperty(i)) {
                    tag$$1.mixin(globalMixin[i]);
                }
            }
        }
        if (__.impl.fn) {
            __.impl.fn.call(tag$$1, opts);
        }
        if (!__.skipAnonymous) {
            tag$$1.trigger("before-mount");
        }
        each(parseExpressions.apply(tag$$1, [ dom, __.isAnonymous ]), function(e) {
            return expressions.push(e);
        });
        tag$$1.update(__.item);
        if (!__.isAnonymous && !__.isInline) {
            while (dom.firstChild) {
                root.appendChild(dom.firstChild);
            }
        }
        define(tag$$1, "root", root);
        if (!__.skipAnonymous && tag$$1.parent) {
            var p = getImmediateCustomParent(tag$$1.parent);
            p.one(!p.isMounted ? "mount" : "updated", function() {
                setMountState.call(tag$$1, true);
            });
        } else {
            setMountState.call(tag$$1, true);
        }
        tag$$1.__.wasCreated = true;
        return tag$$1;
    }
    function tagUnmount(tag, mustKeepRoot, expressions) {
        var __ = tag.__;
        var root = __.root;
        var tagIndex = __TAGS_CACHE.indexOf(tag);
        var p = root.parentNode;
        if (!__.skipAnonymous) {
            tag.trigger("before-unmount");
        }
        walkAttributes(__.impl.attrs, function(name) {
            if (startsWith(name, ATTRS_PREFIX)) {
                name = name.slice(ATTRS_PREFIX.length);
            }
            removeAttribute(root, name);
        });
        tag.__.listeners.forEach(function(dom) {
            Object.keys(dom[RIOT_EVENTS_KEY]).forEach(function(eventName) {
                dom.removeEventListener(eventName, dom[RIOT_EVENTS_KEY][eventName]);
            });
        });
        if (tagIndex !== -1) {
            __TAGS_CACHE.splice(tagIndex, 1);
        }
        if (__.parent && !__.isAnonymous) {
            var ptag = getImmediateCustomParent(__.parent);
            if (__.isVirtual) {
                Object.keys(tag.tags).forEach(function(tagName) {
                    return arrayishRemove(ptag.tags, tagName, tag.tags[tagName]);
                });
            } else {
                arrayishRemove(ptag.tags, __.tagName, tag);
            }
        }
        if (tag.__.virts) {
            each(tag.__.virts, function(v) {
                if (v.parentNode) {
                    v.parentNode.removeChild(v);
                }
            });
        }
        unmountAll(expressions);
        each(__.instAttrs, function(a) {
            return a.expr && a.expr.unmount && a.expr.unmount();
        });
        if (mustKeepRoot) {
            setInnerHTML(root, "");
        } else if (p) {
            p.removeChild(root);
        }
        if (__.onUnmount) {
            __.onUnmount();
        }
        if (!tag.isMounted) {
            setMountState.call(tag, true);
        }
        setMountState.call(tag, false);
        delete root._tag;
        return tag;
    }
    function createTag(impl, conf, innerHTML) {
        if (impl === void 0) impl = {};
        if (conf === void 0) conf = {};
        var tag = conf.context || {};
        var opts = conf.opts || {};
        var parent = conf.parent;
        var isLoop = conf.isLoop;
        var isAnonymous = !!conf.isAnonymous;
        var skipAnonymous = settings.skipAnonymousTags && isAnonymous;
        var item = conf.item;
        var index = conf.index;
        var instAttrs = [];
        var implAttrs = [];
        var tmpl = impl.tmpl;
        var expressions = [];
        var root = conf.root;
        var tagName = conf.tagName || getName(root);
        var isVirtual = tagName === "virtual";
        var isInline = !isVirtual && !tmpl;
        var dom;
        if (isInline || isLoop && isAnonymous) {
            dom = root;
        } else {
            if (!isVirtual) {
                root.innerHTML = "";
            }
            dom = mkdom(tmpl, innerHTML, isSvg(root));
        }
        if (!skipAnonymous) {
            observable(tag);
        }
        if (impl.name && root._tag) {
            root._tag.unmount(true);
        }
        define(tag, "__", {
            impl: impl,
            root: root,
            skipAnonymous: skipAnonymous,
            implAttrs: implAttrs,
            isAnonymous: isAnonymous,
            instAttrs: instAttrs,
            innerHTML: innerHTML,
            tagName: tagName,
            index: index,
            isLoop: isLoop,
            isInline: isInline,
            item: item,
            parent: parent,
            listeners: [],
            virts: [],
            wasCreated: false,
            tail: null,
            head: null
        });
        return [ [ "isMounted", false ], [ "_riot_id", uid() ], [ "root", root ], [ "opts", opts, {
            writable: true,
            enumerable: true
        } ], [ "parent", parent || null ], [ "tags", {} ], [ "refs", {} ], [ "update", function(data) {
            return componentUpdate(tag, data, expressions);
        } ], [ "mixin", function() {
            var mixins = [], len = arguments.length;
            while (len--) mixins[len] = arguments[len];
            return componentMixin.apply(void 0, [ tag ].concat(mixins));
        } ], [ "mount", function() {
            return componentMount(tag, dom, expressions, opts);
        } ], [ "unmount", function(mustKeepRoot) {
            return tagUnmount(tag, mustKeepRoot, expressions);
        } ] ].reduce(function(acc, ref) {
            var key = ref[0];
            var value = ref[1];
            var opts = ref[2];
            define(tag, key, value, opts);
            return acc;
        }, extend(tag, item));
    }
    function mount$1(root, tagName, opts, ctx) {
        var impl = __TAG_IMPL[tagName];
        var implClass = __TAG_IMPL[tagName].class;
        var context = ctx || (implClass ? create(implClass.prototype) : {});
        var innerHTML = root._innerHTML = root._innerHTML || root.innerHTML;
        var conf = extend({
            root: root,
            opts: opts,
            context: context
        }, {
            parent: opts ? opts.parent : null
        });
        var tag;
        if (impl && root) {
            tag = createTag(impl, conf, innerHTML);
        }
        if (tag && tag.mount) {
            tag.mount(true);
            if (!contains(__TAGS_CACHE, tag)) {
                __TAGS_CACHE.push(tag);
            }
        }
        return tag;
    }
    var tags = Object.freeze({
        arrayishAdd: arrayishAdd,
        getTagName: getName,
        inheritParentProps: inheritParentProps,
        mountTo: mount$1,
        selectTags: query,
        arrayishRemove: arrayishRemove,
        getTag: get,
        initChildTag: initChild,
        moveChildTag: moveChild,
        makeReplaceVirtual: makeReplaceVirtual,
        getImmediateCustomParentTag: getImmediateCustomParent,
        makeVirtual: makeVirtual,
        moveVirtual: moveVirtual,
        unmountAll: unmountAll,
        createIfDirective: createIfDirective,
        createRefDirective: createRefDirective
    });
    var settings$1 = settings;
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
    var Tag$1 = Tag;
    var tag$1 = tag;
    var tag2$1 = tag2;
    var mount$2 = mount;
    var mixin$1 = mixin;
    var update$2 = update$1;
    var unregister$1 = unregister;
    var version$1 = version;
    var observable$1 = observable;
    var riot$1 = extend({}, core, {
        observable: observable,
        settings: settings$1,
        util: util
    });
    exports.settings = settings$1;
    exports.util = util;
    exports.Tag = Tag$1;
    exports.tag = tag$1;
    exports.tag2 = tag2$1;
    exports.mount = mount$2;
    exports.mixin = mixin$1;
    exports.update = update$2;
    exports.unregister = unregister$1;
    exports.version = version$1;
    exports.observable = observable$1;
    exports.default = riot$1;
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

if (window.wAppNoSessionLoad) {
    window.korSessionPromise.success(function(data) {
        window.wApp.data = data;
        wApp.bus.trigger("auth-data");
        return riot.update();
    });
} else {
    Zepto.ajax({
        url: "/api/1.0/info",
        success: function(data) {
            window.wApp.data = data;
            wApp.bus.trigger("auth-data");
            return riot.update();
        }
    });
}

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

wApp.session = {
    data: function() {
        return wApp.data;
    }
};

wApp.mixins.session = {
    init: function() {
        var redirectDenied, tag;
        tag = this;
        redirectDenied = function() {
            var j, len, redirect, ref, rr, user;
            redirect = false;
            ref = tag.requireRoles;
            for (j = 0, len = ref.length; j < len; j++) {
                rr = ref[j];
                if (user = wApp.data.session.user) {
                    if (!user.auth.roles[rr]) {
                        redirect = true;
                    }
                } else {
                    redirect = true;
                }
            }
            if (redirect) {
                return window.location.hash = "#/denied";
            }
        };
        if (wApp.data && wApp.data.session) {
            return redirectDenied();
        } else {
            return wApp.bus.one("auth-data", function() {
                return redirectDenied();
            });
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

riot.tag2("kor-entity-editor", '<h1>Entity Editor</h1> <div class="hr"></div> <form> <kor-field field-id="name" label-key="entity.name" model="{opts.entity}" errors="{errors.name}"></kor-field> <kor-field field-id="distinct_name" label-key="entity.distinct_name" model="{opts.entity}" errors="{errors.distinct_name}"></kor-field> <kor-field field-id="distinct_name" label-key="entity.distinct_name" model="{opts.entity}" errors="{errors.distinct_name}"></kor-field> </form>', "", "", function(opts) {
    var tag;
    tag = this;
});

riot.tag2("kor-field-editor", '<h2> <kor-t key="objects.edit" with="{{\'interpolations\': {\'o\': wApp.i18n.translate(\'activerecord.models.field\', {count: \'other\'})}}}" show="{opts.kind.id}"></kor-t> </h2> <form if="{showForm && types}" onsubmit="{submit}"> <kor-field field-id="type" label-key="field.type" type="select" options="{types_for_select}" allow-no-selection="{false}" riot-value="{field.type}" is-disabled="{field.id}"></kor-field> <virtual each="{f in specialFields}"> <kor-field field-id="{f.name}" label="{f.label}" model="{field}" errors="{errors[f.name]}"></kor-field> </virtual> <kor-field field-id="name" label-key="field.name" model="{field}" errors="{errors.name}"></kor-field> <kor-field field-id="show_label" label-key="field.show_label" model="{field}" errors="{errors.show_label}"></kor-field> <kor-field field-id="form_label" label-key="field.form_label" model="{field}" errors="{errors.form_label}"></kor-field> <kor-field field-id="search_label" label-key="field.search_label" model="{field}" errors="{errors.search_label}"></kor-field> <kor-field field-id="show_on_entity" type="checkbox" label-key="field.show_on_entity" model="{field}"></kor-field> <kor-field field-id="is_identifier" type="checkbox" label-key="field.is_identifier" model="{field}"></kor-field> <div class="hr"></div> <kor-submit></kor-submit> </form>', "", "", function(opts) {
    var create, params, tag, update;
    tag = this;
    tag.errors = {};
    tag.opts.notify.on("add-field", function() {
        tag.field = {
            type: "Fields::String"
        };
        tag.showForm = true;
        return tag.update();
    });
    tag.opts.notify.on("edit-field", function(field) {
        tag.field = field;
        tag.showForm = true;
        return tag.update();
    });
    tag.on("mount", function() {
        return Zepto.ajax({
            url: "/kinds/" + tag.opts.kind.id + "/fields/types",
            success: function(data) {
                var i, len, results1, t;
                tag.types = {};
                tag.types_for_select = [];
                results1 = [];
                for (i = 0, len = data.length; i < len; i++) {
                    t = data[i];
                    tag.types_for_select.push({
                        value: t.name,
                        label: t.label
                    });
                    results1.push(tag.types[t.name] = t);
                }
                return results1;
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
                return tag.errors = data.errors;
            },
            complete: function() {
                return tag.update();
            }
        });
    };
    update = function() {
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

riot.tag2("kor-fields", '<div class="pull-right"> <a href="#/kinds/{opts.kind.id}/fields/new" onclick="{add}"> <i class="fa fa-plus-square"></i> </a> </div> <strong> <kor-t key="activerecord.models.field" with="{{count: \'other\', capitalize: true}}"> /> </strong> <ul if="{kind}"> <li each="{field in kind.fields}"> <div class="pull-right"> <a href="#" onclick="{edit(field)}"><i class="fa fa-edit"></i></a> <a href="#" onclick="{remove(field)}"><i class="fa fa-remove"></i></a> </div> <a href="#" onclick="{edit(field)}">{field.name}</a> </li> </ul>', "", "", function(opts) {
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
    refresh = function() {
        return Zepto.ajax({
            url: "/kinds/" + tag.opts.kind.id,
            data: {
                include: "fields,inheritance"
            },
            success: function(data) {
                tag.kind = data;
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
                return tag.errors = data.errors;
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

riot.tag2("kor-generators", '<div class="pull-right"> <a href="#/kinds/{opts.kind.id}/generators/new" onclick="{add}"> <i class="fa fa-plus-square"></i> </a> </div> <strong> <kor-t key="activerecord.models.generator" with="{{count: \'other\', capitalize: true}}"> /> </strong> <ul if="{kind}"> <li each="{generator in kind.generators}"> <div class="pull-right"> <a href="#" onclick="{edit(generator)}"><i class="fa fa-edit"></i></a> <a href="#" onclick="{remove(generator)}"><i class="fa fa-remove"></i></a> </div> <a href="#" onclick="{edit(generator)}">{generator.name}</a> </li> </ul>', "", "", function(opts) {
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
    refresh = function() {
        return Zepto.ajax({
            url: "/kinds/" + tag.opts.kind.id,
            data: {
                include: "generators,inheritance"
            },
            success: function(data) {
                tag.kind = data;
                return tag.update();
            }
        });
    };
});

riot.tag2("kor-kind-editor", '<kor-menu-fix></kor-menu-fix> <kor-layout-panel class="left small" if="{opts.kind}"> <kor-panel> <h1> <span show="{opts.kind.id}">{opts.kind.name}</span> <kor-t show="{!opts.kind.id}" key="objects.create" with="{{\'interpolations\': {\'o\': wApp.i18n.translate(\'activerecord.models.kind\')}}}"></kor-t> </h1> <a href="#" onclick="{switchTo(\'general\')}"> » {wApp.i18n.translate(\'general\', {capitalize: true})} </a><br> <a href="#" onclick="{switchTo(\'fields\')}" if="{opts.kind.id}"> » {wApp.i18n.translate(\'activerecord.models.field\', {count: \'other\', capitalize: true})} </a><br> <a href="#" onclick="{switchTo(\'generators\')}" if="{opts.kind.id}"> » {wApp.i18n.translate(\'activerecord.models.generator\', {count: \'other\', capitalize: true})} </a><br> <div class="hr"></div> <div class="text-right"> <a href="#/kinds" class="kor-button">{wApp.i18n.t(\'back_to_list\')}</a> </div> <div class="hr" if="{tab == \'fields\' || tab == \'generators\'}"></div> <kor-fields kind="{opts.kind}" if="{tab == \'fields\'}" notify="{notify}"></kor-fields> <kor-generators kind="{opts.kind}" if="{tab == \'generators\'}" notify="{notify}"></kor-generators> </kor-panel> </kor-layout-panel> <kor-layout-panel class="right large"> <kor-panel> <kor-kind-general-editor if="{tab == \'general\'}" kind="{opts.kind}" notify="{notify}"></kor-kind-general-editor> <kor-field-editor kind="{opts.kind}" if="{tab == \'fields\' && opts.kind.id}" notify="{notify}"></kor-field-editor> <kor-generator-editor kind="{opts.kind}" if="{tab == \'generators\' && opts.kind.id}" notify="{notify}"></kor-generator-editor> </kor-panel> </kor-layout-panel>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.tab = "general";
    tag.notify = riot.observable();
    tag.requireRoles = [ "kind_admin" ];
    tag.mixin(wApp.mixins.session);
    tag.on("mount", function() {
        if (tag.opts.id) {
            return Zepto.ajax({
                url: "/kinds/" + tag.opts.id,
                data: {
                    include: "settings,fields,generators,inheritance"
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
        wApp.bus.trigger("kinds-changed");
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

riot.tag2("kor-kind-general-editor", '<h2 if="{opts.kind}"> <kor-t key="general" with="{{capitalize: true}}" show="{opts.kind.id}"></kor-t> <kor-t show="{!opts.kind.id}" key="objects.create" with="{{\'interpolations\': {\'o\': wApp.i18n.translate(\'activerecord.models.kind\')}}}"></kor-t> </h2> <form onsubmit="{submit}" if="{possible_parents}"> <kor-field field-id="schema" label-key="kind.schema" model="{opts.kind}"></kor-field> <kor-field field-id="name" label-key="kind.name" model="{opts.kind}" errors="{errors.name}"></kor-field> <kor-field field-id="plural_name" label-key="kind.plural_name" model="{opts.kind}" errors="{errors.plural_name}"></kor-field> <kor-field field-id="description" type="textarea" label-key="kind.description" model="{opts.kind}"></kor-field> <kor-field field-id="url" label-key="kind.url" model="{opts.kind}"></kor-field> <kor-field field-id="parent_ids" type="select" options="{possible_parents}" multiple="{true}" label-key="kind.parent" model="{opts.kind}" errors="{errors.parent_ids}"></kor-field> <kor-field field-id="abstract" type="checkbox" label-key="kind.abstract" model="{opts.kind}"></kor-field> <kor-field field-id="tagging" type="checkbox" label-key="kind.tagging" model="{opts.kind}"></kor-field> <div if="{!is_media()}"> <kor-field field-id="dating_label" label-key="kind.dating_label" model="{opts.kind}"></kor-field> <kor-field field-id="name_label" label-key="kind.name_label" model="{opts.kind}"></kor-field> <kor-field field-id="distinct_name_label" label-key="kind.distinct_name_label" model="{opts.kind}"></kor-field> </div> <div class="hr"></div> <kor-submit></kor-submit> </form>', "", "", function(opts) {
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

riot.tag2("kor-field", '<label> {label()} <input if="{has_input()}" type="{inputType()}" name="{opts.fieldId}" riot-value="{value()}" checked="{checked()}"> <textarea if="{has_textarea()}" name="{opts.fieldId}">{value()}</textarea> <select if="{has_select()}" name="{opts.fieldId}" multiple="{opts.multiple}" disabled="{opts.isDisabled}"> <option if="{opts.allowNoSelection}" riot-value="{undefined}" selected="{!!value()}">{noSelectionLabel()}</option> <option each="{o in opts.options}" riot-value="{o.value}" selected="{selected(o.value)}">{o.label}</option> </select> <ul if="{has_errors()}" class="errors"> <li each="{error in errors()}">{error}</li> </ul> </label>', "", "class=\"{'errors': has_errors()}\"", function(opts) {
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
        var v;
        v = tag.opts.model ? tag.opts.model[tag.opts.fieldId] : tag.opts.riotValue;
        if (v && tag.opts.multiple) {
            return v.indexOf(key) > -1;
        } else {
            return v === key;
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

riot.tag2("kor-kinds", '<h1> {wApp.i18n.t(\'activerecord.models.kind\', {capitalize: true, count: \'other\'})} </h1> <form class="kor-horizontal"> <kor-field label-key="search_term" field-id="terms" onkeyup="{delayedSubmit}"></kor-field> <kor-field label-key="hide_abstract" type="checkbox" field-id="hideAbstract" onchange="{submit}"></kor-field> <div class="hr"></div> </form> <div class="text-right"> <a href="#/kinds/new"> <i class="fa fa-plus-square"></i> </a> </div> <virtual if="{filteredRecords && filteredRecords.length}"> <table each="{records, schema in groupedResults}" class="kor_table text-left"> <thead> <tr> <th>{schema == \'null\' ? t(\'no_schema\', {capitalize: true}) : schema}</th> <th></th> </tr> </thead> <tbody> <tr each="{kind in records}"> <td class="{active: !kind.abstract}"> <div class="name"> <a href="#/kinds/{kind.id}">{kind.name}</a> </div> <div show="{kind.fields.length}"> <span class="label"> {wApp.i18n.t(\'activerecord.models.field\', {count: \'other\'})}: </span> {fieldNamesFor(kind)} </div> <div show="{kind.generators.length}"> <span class="label"> {wApp.i18n.t(\'activerecord.models.generator\', {count: \'other\'})}: </span> {generatorNamesFor(kind)} </div> </td> <td class="text-right buttons"> <a href="#/kinds/{kind.id}"><i class="fa fa-edit"></i></a> <a if="{kind.removable}" href="#/kinds/{kind.id}" onclick="{delete(kind)}"><i class="fa fa-remove"></i></a> </td> </tr> </tbody> </table> </virtual>', "", "", function(opts) {
    var fetch, filter_records, groupAndSortRecords, tag, typeCompare;
    tag = this;
    tag.requireRoles = [ "kind_admin" ];
    tag.mixin(wApp.mixins.session);
    tag.t = wApp.i18n.t;
    tag.on("mount", function() {
        return fetch();
    });
    tag.filters = {};
    tag["delete"] = function(kind) {
        return function(event) {
            event.preventDefault();
            if (wApp.utils.confirm(wApp.i18n.translate("confirm.general"))) {
                return Zepto.ajax({
                    type: "delete",
                    url: "/kinds/" + kind.id,
                    success: function() {
                        return fetch();
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
        groupAndSortRecords();
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
    filter_records = function() {
        var kind, re, results;
        tag.filteredRecords = function() {
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
            return tag.filteredRecords = tag.filteredRecords.filter(function(kind) {
                return !kind.abstract;
            });
        }
    };
    typeCompare = function(x, y) {
        if (x.match(/^E\d+/) && y.match(/^E\d+/)) {
            x = parseInt(x.replace(/^E/, "").split(" ")[0]);
            y = parseInt(y.replace(/^E/, "").split(" ")[0]);
        }
        if (x > y) {
            return 1;
        } else {
            if (x === y) {
                return 0;
            } else {
                return -1;
            }
        }
    };
    groupAndSortRecords = function() {
        var i, k, len, name, r, ref, results, v;
        results = {};
        ref = tag.filteredRecords;
        for (i = 0, len = ref.length; i < len; i++) {
            r = ref[i];
            results[name = r["schema"]] || (results[name] = []);
            results[r["schema"]].push(r);
        }
        for (k in results) {
            v = results[k];
            results[k] = v.sort(function(x, y) {
                return typeCompare(x.name, y.name);
            });
        }
        return tag.groupedResults = results;
    };
    fetch = function() {
        return Zepto.ajax({
            type: "get",
            url: "/kinds",
            data: {
                include: "generators,fields,inheritance"
            },
            success: function(data) {
                tag.data = data;
                filter_records();
                groupAndSortRecords();
                return tag.update();
            }
        });
    };
});

riot.tag2("kor-menu-fix", "", "", "", function(opts) {
    var fixMenu, tag;
    tag = this;
    tag.on("mount", function() {
        return wApp.bus.on("kinds-changed", fixMenu);
    });
    tag.on("unmount", function() {
        return wApp.bus.off("kinds-changed", fixMenu);
    });
    fixMenu = function() {
        return Zepto.ajax({
            url: "/kinds",
            data: {
                only_active: true
            },
            success: function(data) {
                var i, kind, len, placeholder, ref, results, select;
                select = Zepto("#new_entity_kind_id");
                placeholder = select.find("option:first-child").remove();
                select.find("option").remove();
                select.append(placeholder);
                ref = data.records;
                results = [];
                for (i = 0, len = ref.length; i < len; i++) {
                    kind = ref[i];
                    results.push(select.append('<option value="' + kind.id + '">' + kind.name + "</option>"));
                }
                return results;
            }
        });
    };
});

riot.tag2("kor-relation-editor", '<kor-layout-panel class="left large"> <kor-panel> <h1> <span show="{opts.id}" if="{relation}">{relation.name}</span> <span show="{!opts.id}"> {wApp.i18n.t(\'objects.create\', {               \'interpolations\': {                 \'o\': wApp.i18n.t(\'activerecord.models.relation\')               }             })} </span> </h1> <form onsubmit="{submit}" if="{relation && possible_parents}"> <kor-field field-id="schema" label-key="relation.schema" model="{relation}"></kor-field> <kor-field field-id="name" label-key="relation.name" model="{relation}" errors="{errors.name}"></kor-field> <kor-field field-id="reverse_name" label-key="relation.reverse_name" model="{relation}" errors="{errors.reverse_name}"></kor-field> <kor-field field-id="description" type="textarea" label-key="relation.description" model="{relation}"></kor-field> <kor-field if="{possible_kinds}" field-id="from_kind_id" type="select" options="{possible_kinds}" label-key="relation.from_kind_id" model="{relation}" errors="{errors.from_kind_id}"></kor-field> <kor-field if="{possible_kinds}" field-id="to_kind_id" type="select" options="{possible_kinds}" label-key="relation.to_kind_id" model="{relation}" errors="{errors.to_kind_id}"></kor-field> <kor-field field-id="parent_ids" type="select" options="{possible_parents}" multiple="{true}" label-key="relation.parent" model="{relation}" errors="{errors.parent_ids}"></kor-field> <kor-field field-id="abstract" type="checkbox" label-key="relation.abstract" model="{relation}"></kor-field> <div class="hr"></div> <kor-submit></kor-submit> </form> </kor-panel> </kor-layout-panel>', "", "", function(opts) {
    var error, fetch, fetchPossibleKinds, fetchPossibleParents, success, tag;
    tag = this;
    window.t = tag;
    tag.on("mount", function() {
        tag.errors = {};
        if (tag.opts.id) {
            fetch();
        } else {
            tag.relation = {};
            tag.update();
        }
        fetchPossibleParents();
        return fetchPossibleKinds();
    });
    fetch = function() {
        return Zepto.ajax({
            url: "/relations/" + tag.opts.id,
            data: {
                include: "inheritance,technical"
            },
            success: function(data) {
                tag.relation = data;
                return tag.update();
            }
        });
    };
    fetchPossibleParents = function() {
        return Zepto.ajax({
            type: "get",
            url: "/relations",
            success: function(data) {
                var i, len, ref, relation;
                tag.possible_parents = [];
                ref = data.records;
                for (i = 0, len = ref.length; i < len; i++) {
                    relation = ref[i];
                    if (parseInt(tag.opts.id) !== relation.id) {
                        tag.possible_parents.push({
                            label: relation.name,
                            value: relation.id
                        });
                    }
                }
                return tag.update();
            }
        });
    };
    fetchPossibleKinds = function() {
        return Zepto.ajax({
            url: "/kinds",
            success: function(data) {
                var i, kind, len, ref;
                tag.possible_kinds = [];
                ref = data.records;
                for (i = 0, len = ref.length; i < len; i++) {
                    kind = ref[i];
                    tag.possible_kinds.push({
                        label: kind.name,
                        value: kind.id
                    });
                }
                return tag.update();
            }
        });
    };
    tag.new_record = function() {
        return !tag.opts.id;
    };
    tag.values = function() {
        var field, i, len, ref, result;
        result = {
            lock_version: tag.relation.lock_version
        };
        ref = tag.tags["kor-field"];
        for (i = 0, len = ref.length; i < len; i++) {
            field = ref[i];
            result[field.fieldId()] = field.val();
        }
        return result;
    };
    success = function(data) {
        window.location.hash = "/relations";
        tag.errors = {};
        return tag.update();
    };
    error = function(response) {
        var data;
        data = JSON.parse(response.response);
        tag.errors = data.errors;
        tag.relation = data.record;
        return tag.update();
    };
    tag.submit = function(event) {
        event.preventDefault();
        if (tag.new_record()) {
            return Zepto.ajax({
                type: "POST",
                url: "/relations",
                data: JSON.stringify({
                    relation: tag.values()
                }),
                success: success,
                error: error
            });
        } else {
            return Zepto.ajax({
                type: "PATCH",
                url: "/relations/" + tag.opts.id,
                data: JSON.stringify({
                    relation: tag.values()
                }),
                success: success,
                error: error
            });
        }
    };
});

riot.tag2("kor-relation-merger", '{wApp.i18n.t(\'messages.relation_merger_prompt\')} <ul if="{ids(true).length > 0}"> <li each="{relation, id in relations}"> <a href="#" onclick="{setAsTarget}">{relation.name} / {relation.reverse_name}</a> ({relation.id}) <i if="{relation.id == target}" class="fa fa-star"></i> <a title="{wApp.i18n.t(\'verbs.remove\')}" href="#" onclick="{removeRelation}"><i class="fa fa-times"></i></a> </li> </ul> <div class="text-right" if="{valid()}"> <button onclick="{check}">{wApp.i18n.t(\'verbs.check\')}</button> <button onclick="{merge}">{wApp.i18n.t(\'verbs.merge\')}</button> </div>', "", "", function(opts) {
    var tag = this;
    tag.relations = {};
    tag.target = null;
    tag.reset = function() {
        tag.relations = {};
        tag.target = null;
    };
    tag.addRelation = function(relation) {
        tag.relations[relation.id] = relation;
        tag.update();
    };
    tag.removeRelation = function(event) {
        event.preventDefault();
        var id = event.item.relation.id;
        delete tag.relations[id];
        if (tag.target == id) {
            tag.target = null;
        }
        tag.update();
    };
    tag.setAsTarget = function(event) {
        event.preventDefault();
        var id = event.item.relation.id;
        tag.target = id;
        tag.update();
    };
    tag.ids = function(includeTarget) {
        var results = [];
        Zepto.each(tag.relations, function(k, v) {
            k = parseInt(k);
            if (includeTarget || k != tag.target) {
                results.push(k);
            }
        });
        return results;
    };
    tag.valid = function() {
        return tag.target && tag.ids().length > 0;
    };
    tag.check = function() {
        submit(true);
    };
    tag.merge = function() {
        if (window.confirm(wApp.i18n.t("confirm.long_time_warning"))) {
            submit(false);
        }
    };
    var done = function() {
        var h = tag.opts.onDone;
        if (h) {
            h();
        }
    };
    var submit = function(check_only) {
        var params = {
            other_id: tag.ids()
        };
        if (check_only != false) {
            params["check_only"] = true;
        }
        Zepto.ajax({
            type: "POST",
            url: "/relations/" + tag.target + "/merge",
            data: JSON.stringify(params),
            success: function(data) {
                if (check_only == false) {
                    done();
                }
            },
            error: function() {
                console.log(arguments);
            }
        });
    };
});

riot.tag2("kor-relations", '<h1> {wApp.i18n.t(\'activerecord.models.relation\', {capitalize: true, count: \'other\'})} </h1> <form class="kor-horizontal"> <kor-field label-key="search_term" field-id="terms" onkeyup="{delayedSubmit}"></kor-field> <div class="hr"></div> </form> <div class="text-right buttons"> <a href="#" title="{wApp.i18n.t(\'verbs.merge\')}" onclick="{toggleMerge}"> <i class="fa fa-compress" aria-hidden="true"></i> </a> <a href="#/relations/new" title="{wApp.i18n.t(\'objects.new\', {interpolations: {o: wApp.i18n.t(\'activerecord.models.relation\')}})}"> <i class="fa fa-plus-square"></i> </a> </div> <div show="{merge}"> <div class="hr"></div> <kor-relation-merger ref="merger" on-done="{mergeDone}"></kor-relation-merger> <div class="hr"></div> </div> <div if="{filteredRecords && !filteredRecords.length}"> {wApp.i18n.t(\'objects.none_found\', {       interpolations: {o: \'activerecord.models.relation.other\'},       capitalize: true     })} </div> <table class="kor_table text-left" each="{records, schema in groupedResults}"> <thead> <tr> <th> {wApp.i18n.t(\'activerecord.attributes.relation.name\', {capitalize: true})} <span if="{schema == \'null\' || !schema}"> ({wApp.i18n.t(\'no_schema\')}) </span> <span if="{schema && schema != \'null\'}"> ({wApp.i18n.t(\'activerecord.attributes.relation.schema\')}: {schema}) </span> </th> <th> {wApp.i18n.t(\'activerecord.attributes.relation.from_kind_id\', {capitalize: true})}<br> {wApp.i18n.t(\'activerecord.attributes.relation.to_kind_id\', {capitalize: true})} </th> </tr> </thead> <tbody> <tr each="{relation in records}"> <td> <a href="#/relations/{relation.id}"> {relation.name} / {relation.reverse_name} </a> </td> <td> <div if="{kindLookup}"> <span class="label"> {wApp.i18n.t(\'activerecord.attributes.relationship.from_id\', {capitalize: true})}: </span> {kind(relation.from_kind_id)} </div> <div if="{kindLookup}"> <span class="label"> {wApp.i18n.t(\'activerecord.attributes.relationship.to_id\', {capitalize: true})}: </span> {kind(relation.to_kind_id)} </div> </td> <td class="text-right buttons"> <a if="{merge}" href="#" onclick="{addToMerge}" title="{wApp.i18n.t(\'add_to_merge\')}"><i class="fa fa-compress"></i></a> <a href="#" onclick="{invert}" title="{wApp.i18n.t(\'verbs.invert\')}"><i class="fa fa-exchange"></i></a> <a href="#/relations/{relation.id}"><i class="fa fa-edit"></i></a> <a if="{relation.removable}" href="#/relations/{relation.id}" onclick="{delete(relation)}"><i class="fa fa-remove"></i></a> </td> </tr> </tbody> </table>', "", "", function(opts) {
    var fetch, fetchKinds, filter_records, groupAndSortRecords, tag, typeCompare;
    tag = this;
    tag.requireRoles = [ "relation_admin" ];
    tag.mixin(wApp.mixins.session);
    tag.on("mount", function() {
        fetch();
        return fetchKinds();
    });
    tag.filters = {};
    tag["delete"] = function(kind) {
        return function(event) {
            event.preventDefault();
            if (wApp.utils.confirm(wApp.i18n.translate("confirm.general"))) {
                return Zepto.ajax({
                    type: "delete",
                    url: "/relations/" + kind.id,
                    success: function() {
                        return fetch();
                    }
                });
            }
        };
    };
    tag.submit = function() {
        tag.filters.terms = tag.formFields["terms"].val();
        tag.filters.hideAbstract = tag.formFields["hideAbstract"].val();
        filter_records();
        groupAndSortRecords();
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
    tag.toggleMerge = function(event) {
        event.preventDefault();
        return tag.merge = !tag.merge;
    };
    tag.addToMerge = function(event) {
        event.preventDefault();
        return tag.refs.merger.addRelation(event.item.relation);
    };
    tag.mergeDone = function() {
        tag.merge = false;
        return fetch();
    };
    tag.invert = function(event) {
        var relation;
        event.preventDefault();
        relation = event.item.relation;
        if (window.confirm(wApp.i18n.t("confirm.long_time_warning"))) {
            return Zepto.ajax({
                type: "PUT",
                url: "/relations/" + relation.id + "/invert",
                success: function(data) {
                    return fetch();
                }
            });
        }
    };
    filter_records = function() {
        var re, relation, results;
        return tag.filteredRecords = function() {
            var i, len, ref;
            if (tag.filters.terms) {
                re = new RegExp("" + tag.filters.terms, "i");
                results = [];
                ref = tag.data.records;
                for (i = 0, len = ref.length; i < len; i++) {
                    relation = ref[i];
                    if (relation.name.match(re) || relation.reverse_name.match(re)) {
                        if (results.indexOf(relation) === -1) {
                            results.push(relation);
                        }
                    }
                }
                return results;
            } else {
                return tag.data.records;
            }
        }();
    };
    typeCompare = function(x, y) {
        if (x.match(/^P\d+/) && y.match(/^P\d+/)) {
            x = parseInt(x.replace(/^P/, "").split(" ")[0]);
            y = parseInt(y.replace(/^P/, "").split(" ")[0]);
        }
        if (x > y) {
            return 1;
        } else {
            if (x === y) {
                return 0;
            } else {
                return -1;
            }
        }
    };
    groupAndSortRecords = function() {
        var i, k, len, name, r, ref, results, v;
        results = {};
        ref = tag.filteredRecords;
        for (i = 0, len = ref.length; i < len; i++) {
            r = ref[i];
            results[name = r["schema"]] || (results[name] = []);
            results[r["schema"]].push(r);
        }
        for (k in results) {
            v = results[k];
            results[k] = v.sort(function(x, y) {
                return typeCompare(x.name, y.name);
            });
        }
        return tag.groupedResults = results;
    };
    tag.kind = function(id) {
        return tag.kindLookup[id].name;
    };
    fetch = function() {
        return Zepto.ajax({
            url: "/relations",
            data: {
                include: "inheritance"
            },
            success: function(data) {
                tag.data = data;
                filter_records();
                groupAndSortRecords();
                tag.refs.merger.reset();
                return tag.update();
            }
        });
    };
    fetchKinds = function() {
        return Zepto.ajax({
            url: "/kinds",
            success: function(data) {
                var i, k, len, ref;
                tag.kindLookup = {};
                ref = data.records;
                for (i = 0, len = ref.length; i < len; i++) {
                    k = ref[i];
                    tag.kindLookup[k.id] = k;
                }
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
        if (contentType && contentType.match(/^application\/json/) && request.response) {
            try {
                data = JSON.parse(request.response);
                if (data.messages.length) {
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

$(document).ready(function(event) {
    riot.mount("*");
});
=======
(function(global,factory){if(typeof define==="function"&&define.amd)define(function(){return factory(global)});else factory(global)})(this,function(window){var Zepto=function(){var undefined,key,$,classList,emptyArray=[],concat=emptyArray.concat,filter=emptyArray.filter,slice=emptyArray.slice,document=window.document,elementDisplay={},classCache={},cssNumber={"column-count":1,columns:1,"font-weight":1,"line-height":1,opacity:1,"z-index":1,zoom:1},fragmentRE=/^\s*<(\w+|!)[^>]*>/,singleTagRE=/^<(\w+)\s*\/?>(?:<\/\1>|)$/,tagExpanderRE=/<(?!area|br|col|embed|hr|img|input|link|meta|param)(([\w:]+)[^>]*)\/>/gi,rootNodeRE=/^(?:body|html)$/i,capitalRE=/([A-Z])/g,methodAttributes=["val","css","html","text","data","width","height","offset"],adjacencyOperators=["after","prepend","before","append"],table=document.createElement("table"),tableRow=document.createElement("tr"),containers={tr:document.createElement("tbody"),tbody:table,thead:table,tfoot:table,td:tableRow,th:tableRow,"*":document.createElement("div")},readyRE=/complete|loaded|interactive/,simpleSelectorRE=/^[\w-]*$/,class2type={},toString=class2type.toString,zepto={},camelize,uniq,tempParent=document.createElement("div"),propMap={tabindex:"tabIndex",readonly:"readOnly",for:"htmlFor",class:"className",maxlength:"maxLength",cellspacing:"cellSpacing",cellpadding:"cellPadding",rowspan:"rowSpan",colspan:"colSpan",usemap:"useMap",frameborder:"frameBorder",contenteditable:"contentEditable"},isArray=Array.isArray||function(object){return object instanceof Array};zepto.matches=function(element,selector){if(!selector||!element||element.nodeType!==1)return false;var matchesSelector=element.matches||element.webkitMatchesSelector||element.mozMatchesSelector||element.oMatchesSelector||element.matchesSelector;if(matchesSelector)return matchesSelector.call(element,selector);var match,parent=element.parentNode,temp=!parent;if(temp)(parent=tempParent).appendChild(element);match=~zepto.qsa(parent,selector).indexOf(element);temp&&tempParent.removeChild(element);return match};function type(obj){return obj==null?String(obj):class2type[toString.call(obj)]||"object"}function isFunction(value){return type(value)=="function"}function isWindow(obj){return obj!=null&&obj==obj.window}function isDocument(obj){return obj!=null&&obj.nodeType==obj.DOCUMENT_NODE}function isObject(obj){return type(obj)=="object"}function isPlainObject(obj){return isObject(obj)&&!isWindow(obj)&&Object.getPrototypeOf(obj)==Object.prototype}function likeArray(obj){var length=!!obj&&"length"in obj&&obj.length,type=$.type(obj);return"function"!=type&&!isWindow(obj)&&("array"==type||length===0||typeof length=="number"&&length>0&&length-1 in obj)}function compact(array){return filter.call(array,function(item){return item!=null})}function flatten(array){return array.length>0?$.fn.concat.apply([],array):array}camelize=function(str){return str.replace(/-+(.)?/g,function(match,chr){return chr?chr.toUpperCase():""})};function dasherize(str){return str.replace(/::/g,"/").replace(/([A-Z]+)([A-Z][a-z])/g,"$1_$2").replace(/([a-z\d])([A-Z])/g,"$1_$2").replace(/_/g,"-").toLowerCase()}uniq=function(array){return filter.call(array,function(item,idx){return array.indexOf(item)==idx})};function classRE(name){return name in classCache?classCache[name]:classCache[name]=new RegExp("(^|\\s)"+name+"(\\s|$)")}function maybeAddPx(name,value){return typeof value=="number"&&!cssNumber[dasherize(name)]?value+"px":value}function defaultDisplay(nodeName){var element,display;if(!elementDisplay[nodeName]){element=document.createElement(nodeName);document.body.appendChild(element);display=getComputedStyle(element,"").getPropertyValue("display");element.parentNode.removeChild(element);display=="none"&&(display="block");elementDisplay[nodeName]=display}return elementDisplay[nodeName]}function children(element){return"children"in element?slice.call(element.children):$.map(element.childNodes,function(node){if(node.nodeType==1)return node})}function Z(dom,selector){var i,len=dom?dom.length:0;for(i=0;i<len;i++)this[i]=dom[i];this.length=len;this.selector=selector||""}zepto.fragment=function(html,name,properties){var dom,nodes,container;if(singleTagRE.test(html))dom=$(document.createElement(RegExp.$1));if(!dom){if(html.replace)html=html.replace(tagExpanderRE,"<$1></$2>");if(name===undefined)name=fragmentRE.test(html)&&RegExp.$1;if(!(name in containers))name="*";container=containers[name];container.innerHTML=""+html;dom=$.each(slice.call(container.childNodes),function(){container.removeChild(this)})}if(isPlainObject(properties)){nodes=$(dom);$.each(properties,function(key,value){if(methodAttributes.indexOf(key)>-1)nodes[key](value);else nodes.attr(key,value)})}return dom};zepto.Z=function(dom,selector){return new Z(dom,selector)};zepto.isZ=function(object){return object instanceof zepto.Z};zepto.init=function(selector,context){var dom;if(!selector)return zepto.Z();else if(typeof selector=="string"){selector=selector.trim();if(selector[0]=="<"&&fragmentRE.test(selector))dom=zepto.fragment(selector,RegExp.$1,context),selector=null;else if(context!==undefined)return $(context).find(selector);else dom=zepto.qsa(document,selector)}else if(isFunction(selector))return $(document).ready(selector);else if(zepto.isZ(selector))return selector;else{if(isArray(selector))dom=compact(selector);else if(isObject(selector))dom=[selector],selector=null;else if(fragmentRE.test(selector))dom=zepto.fragment(selector.trim(),RegExp.$1,context),selector=null;else if(context!==undefined)return $(context).find(selector);else dom=zepto.qsa(document,selector)}return zepto.Z(dom,selector)};$=function(selector,context){return zepto.init(selector,context)};function extend(target,source,deep){for(key in source)if(deep&&(isPlainObject(source[key])||isArray(source[key]))){if(isPlainObject(source[key])&&!isPlainObject(target[key]))target[key]={};if(isArray(source[key])&&!isArray(target[key]))target[key]=[];extend(target[key],source[key],deep)}else if(source[key]!==undefined)target[key]=source[key]}$.extend=function(target){var deep,args=slice.call(arguments,1);if(typeof target=="boolean"){deep=target;target=args.shift()}args.forEach(function(arg){extend(target,arg,deep)});return target};zepto.qsa=function(element,selector){var found,maybeID=selector[0]=="#",maybeClass=!maybeID&&selector[0]==".",nameOnly=maybeID||maybeClass?selector.slice(1):selector,isSimple=simpleSelectorRE.test(nameOnly);return element.getElementById&&isSimple&&maybeID?(found=element.getElementById(nameOnly))?[found]:[]:element.nodeType!==1&&element.nodeType!==9&&element.nodeType!==11?[]:slice.call(isSimple&&!maybeID&&element.getElementsByClassName?maybeClass?element.getElementsByClassName(nameOnly):element.getElementsByTagName(selector):element.querySelectorAll(selector))};function filtered(nodes,selector){return selector==null?$(nodes):$(nodes).filter(selector)}$.contains=document.documentElement.contains?function(parent,node){return parent!==node&&parent.contains(node)}:function(parent,node){while(node&&(node=node.parentNode))if(node===parent)return true;return false};function funcArg(context,arg,idx,payload){return isFunction(arg)?arg.call(context,idx,payload):arg}function setAttribute(node,name,value){value==null?node.removeAttribute(name):node.setAttribute(name,value)}function className(node,value){var klass=node.className||"",svg=klass&&klass.baseVal!==undefined;if(value===undefined)return svg?klass.baseVal:klass;svg?klass.baseVal=value:node.className=value}function deserializeValue(value){try{return value?value=="true"||(value=="false"?false:value=="null"?null:+value+""==value?+value:/^[\[\{]/.test(value)?$.parseJSON(value):value):value}catch(e){return value}}$.type=type;$.isFunction=isFunction;$.isWindow=isWindow;$.isArray=isArray;$.isPlainObject=isPlainObject;$.isEmptyObject=function(obj){var name;for(name in obj)return false;return true};$.isNumeric=function(val){var num=Number(val),type=typeof val;return val!=null&&type!="boolean"&&(type!="string"||val.length)&&!isNaN(num)&&isFinite(num)||false};$.inArray=function(elem,array,i){return emptyArray.indexOf.call(array,elem,i)};$.camelCase=camelize;$.trim=function(str){return str==null?"":String.prototype.trim.call(str)};$.uuid=0;$.support={};$.expr={};$.noop=function(){};$.map=function(elements,callback){var value,values=[],i,key;if(likeArray(elements))for(i=0;i<elements.length;i++){value=callback(elements[i],i);if(value!=null)values.push(value)}else for(key in elements){value=callback(elements[key],key);if(value!=null)values.push(value)}return flatten(values)};$.each=function(elements,callback){var i,key;if(likeArray(elements)){for(i=0;i<elements.length;i++)if(callback.call(elements[i],i,elements[i])===false)return elements}else{for(key in elements)if(callback.call(elements[key],key,elements[key])===false)return elements}return elements};$.grep=function(elements,callback){return filter.call(elements,callback)};if(window.JSON)$.parseJSON=JSON.parse;$.each("Boolean Number String Function Array Date RegExp Object Error".split(" "),function(i,name){class2type["[object "+name+"]"]=name.toLowerCase()});$.fn={constructor:zepto.Z,length:0,forEach:emptyArray.forEach,reduce:emptyArray.reduce,push:emptyArray.push,sort:emptyArray.sort,splice:emptyArray.splice,indexOf:emptyArray.indexOf,concat:function(){var i,value,args=[];for(i=0;i<arguments.length;i++){value=arguments[i];args[i]=zepto.isZ(value)?value.toArray():value}return concat.apply(zepto.isZ(this)?this.toArray():this,args)},map:function(fn){return $($.map(this,function(el,i){return fn.call(el,i,el)}))},slice:function(){return $(slice.apply(this,arguments))},ready:function(callback){if(readyRE.test(document.readyState)&&document.body)callback($);else document.addEventListener("DOMContentLoaded",function(){callback($)},false);return this},get:function(idx){return idx===undefined?slice.call(this):this[idx>=0?idx:idx+this.length]},toArray:function(){return this.get()},size:function(){return this.length},remove:function(){return this.each(function(){if(this.parentNode!=null)this.parentNode.removeChild(this)})},each:function(callback){emptyArray.every.call(this,function(el,idx){return callback.call(el,idx,el)!==false});return this},filter:function(selector){if(isFunction(selector))return this.not(this.not(selector));return $(filter.call(this,function(element){return zepto.matches(element,selector)}))},add:function(selector,context){return $(uniq(this.concat($(selector,context))))},is:function(selector){return this.length>0&&zepto.matches(this[0],selector)},not:function(selector){var nodes=[];if(isFunction(selector)&&selector.call!==undefined)this.each(function(idx){if(!selector.call(this,idx))nodes.push(this)});else{var excludes=typeof selector=="string"?this.filter(selector):likeArray(selector)&&isFunction(selector.item)?slice.call(selector):$(selector);this.forEach(function(el){if(excludes.indexOf(el)<0)nodes.push(el)})}return $(nodes)},has:function(selector){return this.filter(function(){return isObject(selector)?$.contains(this,selector):$(this).find(selector).size()})},eq:function(idx){return idx===-1?this.slice(idx):this.slice(idx,+idx+1)},first:function(){var el=this[0];return el&&!isObject(el)?el:$(el)},last:function(){var el=this[this.length-1];return el&&!isObject(el)?el:$(el)},find:function(selector){var result,$this=this;if(!selector)result=$();else if(typeof selector=="object")result=$(selector).filter(function(){var node=this;return emptyArray.some.call($this,function(parent){return $.contains(parent,node)})});else if(this.length==1)result=$(zepto.qsa(this[0],selector));else result=this.map(function(){return zepto.qsa(this,selector)});return result},closest:function(selector,context){var nodes=[],collection=typeof selector=="object"&&$(selector);this.each(function(_,node){while(node&&!(collection?collection.indexOf(node)>=0:zepto.matches(node,selector)))node=node!==context&&!isDocument(node)&&node.parentNode;if(node&&nodes.indexOf(node)<0)nodes.push(node)});return $(nodes)},parents:function(selector){var ancestors=[],nodes=this;while(nodes.length>0)nodes=$.map(nodes,function(node){if((node=node.parentNode)&&!isDocument(node)&&ancestors.indexOf(node)<0){ancestors.push(node);return node}});return filtered(ancestors,selector)},parent:function(selector){return filtered(uniq(this.pluck("parentNode")),selector)},children:function(selector){return filtered(this.map(function(){return children(this)}),selector)},contents:function(){return this.map(function(){return this.contentDocument||slice.call(this.childNodes)})},siblings:function(selector){return filtered(this.map(function(i,el){return filter.call(children(el.parentNode),function(child){return child!==el})}),selector)},empty:function(){return this.each(function(){this.innerHTML=""})},pluck:function(property){return $.map(this,function(el){return el[property]})},show:function(){return this.each(function(){this.style.display=="none"&&(this.style.display="");if(getComputedStyle(this,"").getPropertyValue("display")=="none")this.style.display=defaultDisplay(this.nodeName)})},replaceWith:function(newContent){return this.before(newContent).remove()},wrap:function(structure){var func=isFunction(structure);if(this[0]&&!func)var dom=$(structure).get(0),clone=dom.parentNode||this.length>1;return this.each(function(index){$(this).wrapAll(func?structure.call(this,index):clone?dom.cloneNode(true):dom)})},wrapAll:function(structure){if(this[0]){$(this[0]).before(structure=$(structure));var children;while((children=structure.children()).length)structure=children.first();$(structure).append(this)}return this},wrapInner:function(structure){var func=isFunction(structure);return this.each(function(index){var self=$(this),contents=self.contents(),dom=func?structure.call(this,index):structure;contents.length?contents.wrapAll(dom):self.append(dom)})},unwrap:function(){this.parent().each(function(){$(this).replaceWith($(this).children())});return this},clone:function(){return this.map(function(){return this.cloneNode(true)})},hide:function(){return this.css("display","none")},toggle:function(setting){return this.each(function(){var el=$(this);(setting===undefined?el.css("display")=="none":setting)?el.show():el.hide()})},prev:function(selector){return $(this.pluck("previousElementSibling")).filter(selector||"*")},next:function(selector){return $(this.pluck("nextElementSibling")).filter(selector||"*")},html:function(html){return 0 in arguments?this.each(function(idx){var originHtml=this.innerHTML;$(this).empty().append(funcArg(this,html,idx,originHtml))}):0 in this?this[0].innerHTML:null},text:function(text){return 0 in arguments?this.each(function(idx){var newText=funcArg(this,text,idx,this.textContent);this.textContent=newText==null?"":""+newText}):0 in this?this.pluck("textContent").join(""):null},attr:function(name,value){var result;return typeof name=="string"&&!(1 in arguments)?0 in this&&this[0].nodeType==1&&(result=this[0].getAttribute(name))!=null?result:undefined:this.each(function(idx){if(this.nodeType!==1)return;if(isObject(name))for(key in name)setAttribute(this,key,name[key]);else setAttribute(this,name,funcArg(this,value,idx,this.getAttribute(name)))})},removeAttr:function(name){return this.each(function(){this.nodeType===1&&name.split(" ").forEach(function(attribute){setAttribute(this,attribute)},this)})},prop:function(name,value){name=propMap[name]||name;return 1 in arguments?this.each(function(idx){this[name]=funcArg(this,value,idx,this[name])}):this[0]&&this[0][name]},removeProp:function(name){name=propMap[name]||name;return this.each(function(){delete this[name]})},data:function(name,value){var attrName="data-"+name.replace(capitalRE,"-$1").toLowerCase();var data=1 in arguments?this.attr(attrName,value):this.attr(attrName);return data!==null?deserializeValue(data):undefined},val:function(value){if(0 in arguments){if(value==null)value="";return this.each(function(idx){this.value=funcArg(this,value,idx,this.value)})}else{return this[0]&&(this[0].multiple?$(this[0]).find("option").filter(function(){return this.selected}).pluck("value"):this[0].value)}},offset:function(coordinates){if(coordinates)return this.each(function(index){var $this=$(this),coords=funcArg(this,coordinates,index,$this.offset()),parentOffset=$this.offsetParent().offset(),props={top:coords.top-parentOffset.top,left:coords.left-parentOffset.left};if($this.css("position")=="static")props["position"]="relative";$this.css(props)});if(!this.length)return null;if(document.documentElement!==this[0]&&!$.contains(document.documentElement,this[0]))return{top:0,left:0};var obj=this[0].getBoundingClientRect();return{left:obj.left+window.pageXOffset,top:obj.top+window.pageYOffset,width:Math.round(obj.width),height:Math.round(obj.height)}},css:function(property,value){if(arguments.length<2){var element=this[0];if(typeof property=="string"){if(!element)return;return element.style[camelize(property)]||getComputedStyle(element,"").getPropertyValue(property)}else if(isArray(property)){if(!element)return;var props={};var computedStyle=getComputedStyle(element,"");$.each(property,function(_,prop){props[prop]=element.style[camelize(prop)]||computedStyle.getPropertyValue(prop)});return props}}var css="";if(type(property)=="string"){if(!value&&value!==0)this.each(function(){this.style.removeProperty(dasherize(property))});else css=dasherize(property)+":"+maybeAddPx(property,value)}else{for(key in property)if(!property[key]&&property[key]!==0)this.each(function(){this.style.removeProperty(dasherize(key))});else css+=dasherize(key)+":"+maybeAddPx(key,property[key])+";"}return this.each(function(){this.style.cssText+=";"+css})},index:function(element){return element?this.indexOf($(element)[0]):this.parent().children().indexOf(this[0])},hasClass:function(name){if(!name)return false;return emptyArray.some.call(this,function(el){return this.test(className(el))},classRE(name))},addClass:function(name){if(!name)return this;return this.each(function(idx){if(!("className"in this))return;classList=[];var cls=className(this),newName=funcArg(this,name,idx,cls);newName.split(/\s+/g).forEach(function(klass){if(!$(this).hasClass(klass))classList.push(klass)},this);classList.length&&className(this,cls+(cls?" ":"")+classList.join(" "))})},removeClass:function(name){return this.each(function(idx){if(!("className"in this))return;if(name===undefined)return className(this,"");classList=className(this);funcArg(this,name,idx,classList).split(/\s+/g).forEach(function(klass){classList=classList.replace(classRE(klass)," ")});className(this,classList.trim())})},toggleClass:function(name,when){if(!name)return this;return this.each(function(idx){var $this=$(this),names=funcArg(this,name,idx,className(this));names.split(/\s+/g).forEach(function(klass){(when===undefined?!$this.hasClass(klass):when)?$this.addClass(klass):$this.removeClass(klass)})})},scrollTop:function(value){if(!this.length)return;var hasScrollTop="scrollTop"in this[0];if(value===undefined)return hasScrollTop?this[0].scrollTop:this[0].pageYOffset;return this.each(hasScrollTop?function(){this.scrollTop=value}:function(){this.scrollTo(this.scrollX,value)})},scrollLeft:function(value){if(!this.length)return;var hasScrollLeft="scrollLeft"in this[0];if(value===undefined)return hasScrollLeft?this[0].scrollLeft:this[0].pageXOffset;return this.each(hasScrollLeft?function(){this.scrollLeft=value}:function(){this.scrollTo(value,this.scrollY)})},position:function(){if(!this.length)return;var elem=this[0],offsetParent=this.offsetParent(),offset=this.offset(),parentOffset=rootNodeRE.test(offsetParent[0].nodeName)?{top:0,left:0}:offsetParent.offset();offset.top-=parseFloat($(elem).css("margin-top"))||0;offset.left-=parseFloat($(elem).css("margin-left"))||0;parentOffset.top+=parseFloat($(offsetParent[0]).css("border-top-width"))||0;parentOffset.left+=parseFloat($(offsetParent[0]).css("border-left-width"))||0;return{top:offset.top-parentOffset.top,left:offset.left-parentOffset.left}},offsetParent:function(){return this.map(function(){var parent=this.offsetParent||document.body;while(parent&&!rootNodeRE.test(parent.nodeName)&&$(parent).css("position")=="static")parent=parent.offsetParent;return parent})}};$.fn.detach=$.fn.remove;["width","height"].forEach(function(dimension){var dimensionProperty=dimension.replace(/./,function(m){return m[0].toUpperCase()});$.fn[dimension]=function(value){var offset,el=this[0];if(value===undefined)return isWindow(el)?el["inner"+dimensionProperty]:isDocument(el)?el.documentElement["scroll"+dimensionProperty]:(offset=this.offset())&&offset[dimension];else return this.each(function(idx){el=$(this);el.css(dimension,funcArg(this,value,idx,el[dimension]()))})}});function traverseNode(node,fun){fun(node);for(var i=0,len=node.childNodes.length;i<len;i++)traverseNode(node.childNodes[i],fun)}adjacencyOperators.forEach(function(operator,operatorIndex){var inside=operatorIndex%2;$.fn[operator]=function(){var argType,nodes=$.map(arguments,function(arg){var arr=[];argType=type(arg);if(argType=="array"){arg.forEach(function(el){if(el.nodeType!==undefined)return arr.push(el);else if($.zepto.isZ(el))return arr=arr.concat(el.get());arr=arr.concat(zepto.fragment(el))});return arr}return argType=="object"||arg==null?arg:zepto.fragment(arg)}),parent,copyByClone=this.length>1;if(nodes.length<1)return this;return this.each(function(_,target){parent=inside?target:target.parentNode;target=operatorIndex==0?target.nextSibling:operatorIndex==1?target.firstChild:operatorIndex==2?target:null;var parentInDocument=$.contains(document.documentElement,parent);nodes.forEach(function(node){if(copyByClone)node=node.cloneNode(true);else if(!parent)return $(node).remove();parent.insertBefore(node,target);if(parentInDocument)traverseNode(node,function(el){if(el.nodeName!=null&&el.nodeName.toUpperCase()==="SCRIPT"&&(!el.type||el.type==="text/javascript")&&!el.src){var target=el.ownerDocument?el.ownerDocument.defaultView:window;target["eval"].call(target,el.innerHTML)}})})})};$.fn[inside?operator+"To":"insert"+(operatorIndex?"Before":"After")]=function(html){$(html)[operator](this);return this}});zepto.Z.prototype=Z.prototype=$.fn;zepto.uniq=uniq;zepto.deserializeValue=deserializeValue;$.zepto=zepto;return $}();window.Zepto=Zepto;window.$===undefined&&(window.$=Zepto);(function($){var _zid=1,undefined,slice=Array.prototype.slice,isFunction=$.isFunction,isString=function(obj){return typeof obj=="string"},handlers={},specialEvents={},focusinSupported="onfocusin"in window,focus={focus:"focusin",blur:"focusout"},hover={mouseenter:"mouseover",mouseleave:"mouseout"};specialEvents.click=specialEvents.mousedown=specialEvents.mouseup=specialEvents.mousemove="MouseEvents";function zid(element){return element._zid||(element._zid=_zid++)}function findHandlers(element,event,fn,selector){event=parse(event);if(event.ns)var matcher=matcherFor(event.ns);return(handlers[zid(element)]||[]).filter(function(handler){return handler&&(!event.e||handler.e==event.e)&&(!event.ns||matcher.test(handler.ns))&&(!fn||zid(handler.fn)===zid(fn))&&(!selector||handler.sel==selector)})}function parse(event){var parts=(""+event).split(".");return{e:parts[0],ns:parts.slice(1).sort().join(" ")}}function matcherFor(ns){return new RegExp("(?:^| )"+ns.replace(" "," .* ?")+"(?: |$)")}function eventCapture(handler,captureSetting){return handler.del&&(!focusinSupported&&handler.e in focus)||!!captureSetting}function realEvent(type){return hover[type]||focusinSupported&&focus[type]||type}function add(element,events,fn,data,selector,delegator,capture){var id=zid(element),set=handlers[id]||(handlers[id]=[]);events.split(/\s/).forEach(function(event){if(event=="ready")return $(document).ready(fn);var handler=parse(event);handler.fn=fn;handler.sel=selector;if(handler.e in hover)fn=function(e){var related=e.relatedTarget;if(!related||related!==this&&!$.contains(this,related))return handler.fn.apply(this,arguments)};handler.del=delegator;var callback=delegator||fn;handler.proxy=function(e){e=compatible(e);if(e.isImmediatePropagationStopped())return;e.data=data;var result=callback.apply(element,e._args==undefined?[e]:[e].concat(e._args));if(result===false)e.preventDefault(),e.stopPropagation();return result};handler.i=set.length;set.push(handler);if("addEventListener"in element)element.addEventListener(realEvent(handler.e),handler.proxy,eventCapture(handler,capture))})}function remove(element,events,fn,selector,capture){var id=zid(element);(events||"").split(/\s/).forEach(function(event){findHandlers(element,event,fn,selector).forEach(function(handler){delete handlers[id][handler.i];if("removeEventListener"in element)element.removeEventListener(realEvent(handler.e),handler.proxy,eventCapture(handler,capture))})})}$.event={add:add,remove:remove};$.proxy=function(fn,context){var args=2 in arguments&&slice.call(arguments,2);if(isFunction(fn)){var proxyFn=function(){return fn.apply(context,args?args.concat(slice.call(arguments)):arguments)};proxyFn._zid=zid(fn);return proxyFn}else if(isString(context)){if(args){args.unshift(fn[context],fn);return $.proxy.apply(null,args)}else{return $.proxy(fn[context],fn)}}else{throw new TypeError("expected function")}};$.fn.bind=function(event,data,callback){return this.on(event,data,callback)};$.fn.unbind=function(event,callback){return this.off(event,callback)};$.fn.one=function(event,selector,data,callback){return this.on(event,selector,data,callback,1)};var returnTrue=function(){return true},returnFalse=function(){return false},ignoreProperties=/^([A-Z]|returnValue$|layer[XY]$|webkitMovement[XY]$)/,eventMethods={preventDefault:"isDefaultPrevented",stopImmediatePropagation:"isImmediatePropagationStopped",stopPropagation:"isPropagationStopped"};function compatible(event,source){if(source||!event.isDefaultPrevented){source||(source=event);$.each(eventMethods,function(name,predicate){var sourceMethod=source[name];event[name]=function(){this[predicate]=returnTrue;return sourceMethod&&sourceMethod.apply(source,arguments)};event[predicate]=returnFalse});event.timeStamp||(event.timeStamp=Date.now());if(source.defaultPrevented!==undefined?source.defaultPrevented:"returnValue"in source?source.returnValue===false:source.getPreventDefault&&source.getPreventDefault())event.isDefaultPrevented=returnTrue}return event}function createProxy(event){var key,proxy={originalEvent:event};for(key in event)if(!ignoreProperties.test(key)&&event[key]!==undefined)proxy[key]=event[key];return compatible(proxy,event)}$.fn.delegate=function(selector,event,callback){return this.on(event,selector,callback)};$.fn.undelegate=function(selector,event,callback){return this.off(event,selector,callback)};$.fn.live=function(event,callback){$(document.body).delegate(this.selector,event,callback);return this};$.fn.die=function(event,callback){$(document.body).undelegate(this.selector,event,callback);return this};$.fn.on=function(event,selector,data,callback,one){var autoRemove,delegator,$this=this;if(event&&!isString(event)){$.each(event,function(type,fn){$this.on(type,selector,data,fn,one)});return $this}if(!isString(selector)&&!isFunction(callback)&&callback!==false)callback=data,data=selector,selector=undefined;if(callback===undefined||data===false)callback=data,data=undefined;if(callback===false)callback=returnFalse;return $this.each(function(_,element){if(one)autoRemove=function(e){remove(element,e.type,callback);return callback.apply(this,arguments)};if(selector)delegator=function(e){var evt,match=$(e.target).closest(selector,element).get(0);if(match&&match!==element){evt=$.extend(createProxy(e),{currentTarget:match,liveFired:element});return(autoRemove||callback).apply(match,[evt].concat(slice.call(arguments,1)))}};add(element,event,callback,data,selector,delegator||autoRemove)})};$.fn.off=function(event,selector,callback){var $this=this;if(event&&!isString(event)){$.each(event,function(type,fn){$this.off(type,selector,fn)});return $this}if(!isString(selector)&&!isFunction(callback)&&callback!==false)callback=selector,selector=undefined;if(callback===false)callback=returnFalse;return $this.each(function(){remove(this,event,callback,selector)})};$.fn.trigger=function(event,args){event=isString(event)||$.isPlainObject(event)?$.Event(event):compatible(event);event._args=args;return this.each(function(){if(event.type in focus&&typeof this[event.type]=="function")this[event.type]();else if("dispatchEvent"in this)this.dispatchEvent(event);else $(this).triggerHandler(event,args)})};$.fn.triggerHandler=function(event,args){var e,result;this.each(function(i,element){e=createProxy(isString(event)?$.Event(event):event);e._args=args;e.target=element;$.each(findHandlers(element,event.type||event),function(i,handler){result=handler.proxy(e);if(e.isImmediatePropagationStopped())return false})});return result};("focusin focusout focus blur load resize scroll unload click dblclick "+"mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave "+"change select keydown keypress keyup error").split(" ").forEach(function(event){$.fn[event]=function(callback){return 0 in arguments?this.bind(event,callback):this.trigger(event)}});$.Event=function(type,props){if(!isString(type))props=type,type=props.type;var event=document.createEvent(specialEvents[type]||"Events"),bubbles=true;if(props)for(var name in props)name=="bubbles"?bubbles=!!props[name]:event[name]=props[name];event.initEvent(type,bubbles,true);return compatible(event)}})(Zepto);(function($){var jsonpID=+new Date,document=window.document,key,name,rscript=/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi,scriptTypeRE=/^(?:text|application)\/javascript/i,xmlTypeRE=/^(?:text|application)\/xml/i,jsonType="application/json",htmlType="text/html",blankRE=/^\s*$/,originAnchor=document.createElement("a");originAnchor.href=window.location.href;function triggerAndReturn(context,eventName,data){var event=$.Event(eventName);$(context).trigger(event,data);return!event.isDefaultPrevented()}function triggerGlobal(settings,context,eventName,data){if(settings.global)return triggerAndReturn(context||document,eventName,data)}$.active=0;function ajaxStart(settings){if(settings.global&&$.active++===0)triggerGlobal(settings,null,"ajaxStart")}function ajaxStop(settings){if(settings.global&&!--$.active)triggerGlobal(settings,null,"ajaxStop")}function ajaxBeforeSend(xhr,settings){var context=settings.context;if(settings.beforeSend.call(context,xhr,settings)===false||triggerGlobal(settings,context,"ajaxBeforeSend",[xhr,settings])===false)return false;triggerGlobal(settings,context,"ajaxSend",[xhr,settings])}function ajaxSuccess(data,xhr,settings,deferred){var context=settings.context,status="success";settings.success.call(context,data,status,xhr);if(deferred)deferred.resolveWith(context,[data,status,xhr]);triggerGlobal(settings,context,"ajaxSuccess",[xhr,settings,data]);ajaxComplete(status,xhr,settings)}function ajaxError(error,type,xhr,settings,deferred){var context=settings.context;settings.error.call(context,xhr,type,error);if(deferred)deferred.rejectWith(context,[xhr,type,error]);triggerGlobal(settings,context,"ajaxError",[xhr,settings,error||type]);ajaxComplete(type,xhr,settings)}function ajaxComplete(status,xhr,settings){var context=settings.context;settings.complete.call(context,xhr,status);triggerGlobal(settings,context,"ajaxComplete",[xhr,settings]);ajaxStop(settings)}function ajaxDataFilter(data,type,settings){if(settings.dataFilter==empty)return data;var context=settings.context;return settings.dataFilter.call(context,data,type)}function empty(){}$.ajaxJSONP=function(options,deferred){if(!("type"in options))return $.ajax(options);var _callbackName=options.jsonpCallback,callbackName=($.isFunction(_callbackName)?_callbackName():_callbackName)||"Zepto"+jsonpID++,script=document.createElement("script"),originalCallback=window[callbackName],responseData,abort=function(errorType){$(script).triggerHandler("error",errorType||"abort")},xhr={abort:abort},abortTimeout;if(deferred)deferred.promise(xhr);$(script).on("load error",function(e,errorType){clearTimeout(abortTimeout);$(script).off().remove();if(e.type=="error"||!responseData){ajaxError(null,errorType||"error",xhr,options,deferred)}else{ajaxSuccess(responseData[0],xhr,options,deferred)}window[callbackName]=originalCallback;if(responseData&&$.isFunction(originalCallback))originalCallback(responseData[0]);originalCallback=responseData=undefined});if(ajaxBeforeSend(xhr,options)===false){abort("abort");return xhr}window[callbackName]=function(){responseData=arguments};script.src=options.url.replace(/\?(.+)=\?/,"?$1="+callbackName);document.head.appendChild(script);if(options.timeout>0)abortTimeout=setTimeout(function(){abort("timeout")},options.timeout);return xhr};$.ajaxSettings={type:"GET",beforeSend:empty,success:empty,error:empty,complete:empty,context:null,global:true,xhr:function(){return new window.XMLHttpRequest},accepts:{script:"text/javascript, application/javascript, application/x-javascript",json:jsonType,xml:"application/xml, text/xml",html:htmlType,text:"text/plain"},crossDomain:false,timeout:0,processData:true,cache:true,dataFilter:empty};function mimeToDataType(mime){if(mime)mime=mime.split(";",2)[0];return mime&&(mime==htmlType?"html":mime==jsonType?"json":scriptTypeRE.test(mime)?"script":xmlTypeRE.test(mime)&&"xml")||"text"}function appendQuery(url,query){if(query=="")return url;return(url+"&"+query).replace(/[&?]{1,2}/,"?")}function serializeData(options){if(options.processData&&options.data&&$.type(options.data)!="string")options.data=$.param(options.data,options.traditional);if(options.data&&(!options.type||options.type.toUpperCase()=="GET"||"jsonp"==options.dataType))options.url=appendQuery(options.url,options.data),options.data=undefined}$.ajax=function(options){var settings=$.extend({},options||{}),deferred=$.Deferred&&$.Deferred(),urlAnchor,hashIndex;for(key in $.ajaxSettings)if(settings[key]===undefined)settings[key]=$.ajaxSettings[key];ajaxStart(settings);if(!settings.crossDomain){urlAnchor=document.createElement("a");urlAnchor.href=settings.url;urlAnchor.href=urlAnchor.href;settings.crossDomain=originAnchor.protocol+"//"+originAnchor.host!==urlAnchor.protocol+"//"+urlAnchor.host}if(!settings.url)settings.url=window.location.toString();if((hashIndex=settings.url.indexOf("#"))>-1)settings.url=settings.url.slice(0,hashIndex);serializeData(settings);var dataType=settings.dataType,hasPlaceholder=/\?.+=\?/.test(settings.url);if(hasPlaceholder)dataType="jsonp";if(settings.cache===false||(!options||options.cache!==true)&&("script"==dataType||"jsonp"==dataType))settings.url=appendQuery(settings.url,"_="+Date.now());if("jsonp"==dataType){if(!hasPlaceholder)settings.url=appendQuery(settings.url,settings.jsonp?settings.jsonp+"=?":settings.jsonp===false?"":"callback=?");return $.ajaxJSONP(settings,deferred)}var mime=settings.accepts[dataType],headers={},setHeader=function(name,value){headers[name.toLowerCase()]=[name,value]},protocol=/^([\w-]+:)\/\//.test(settings.url)?RegExp.$1:window.location.protocol,xhr=settings.xhr(),nativeSetHeader=xhr.setRequestHeader,abortTimeout;if(deferred)deferred.promise(xhr);if(!settings.crossDomain)setHeader("X-Requested-With","XMLHttpRequest");setHeader("Accept",mime||"*/*");if(mime=settings.mimeType||mime){if(mime.indexOf(",")>-1)mime=mime.split(",",2)[0];xhr.overrideMimeType&&xhr.overrideMimeType(mime)}if(settings.contentType||settings.contentType!==false&&settings.data&&settings.type.toUpperCase()!="GET")setHeader("Content-Type",settings.contentType||"application/x-www-form-urlencoded");if(settings.headers)for(name in settings.headers)setHeader(name,settings.headers[name]);xhr.setRequestHeader=setHeader;xhr.onreadystatechange=function(){if(xhr.readyState==4){xhr.onreadystatechange=empty;clearTimeout(abortTimeout);var result,error=false;if(xhr.status>=200&&xhr.status<300||xhr.status==304||xhr.status==0&&protocol=="file:"){dataType=dataType||mimeToDataType(settings.mimeType||xhr.getResponseHeader("content-type"));if(xhr.responseType=="arraybuffer"||xhr.responseType=="blob")result=xhr.response;else{result=xhr.responseText;try{result=ajaxDataFilter(result,dataType,settings);if(dataType=="script")(1,eval)(result);else if(dataType=="xml")result=xhr.responseXML;else if(dataType=="json")result=blankRE.test(result)?null:$.parseJSON(result)}catch(e){error=e}if(error)return ajaxError(error,"parsererror",xhr,settings,deferred)}ajaxSuccess(result,xhr,settings,deferred)}else{ajaxError(xhr.statusText||null,xhr.status?"error":"abort",xhr,settings,deferred)}}};if(ajaxBeforeSend(xhr,settings)===false){xhr.abort();ajaxError(null,"abort",xhr,settings,deferred);return xhr}var async="async"in settings?settings.async:true;xhr.open(settings.type,settings.url,async,settings.username,settings.password);if(settings.xhrFields)for(name in settings.xhrFields)xhr[name]=settings.xhrFields[name];for(name in headers)nativeSetHeader.apply(xhr,headers[name]);if(settings.timeout>0)abortTimeout=setTimeout(function(){xhr.onreadystatechange=empty;xhr.abort();ajaxError(null,"timeout",xhr,settings,deferred)},settings.timeout);xhr.send(settings.data?settings.data:null);return xhr};function parseArguments(url,data,success,dataType){if($.isFunction(data))dataType=success,success=data,data=undefined;if(!$.isFunction(success))dataType=success,success=undefined;return{url:url,data:data,success:success,dataType:dataType}}$.get=function(){return $.ajax(parseArguments.apply(null,arguments))};$.post=function(){var options=parseArguments.apply(null,arguments);options.type="POST";return $.ajax(options)};$.getJSON=function(){var options=parseArguments.apply(null,arguments);options.dataType="json";return $.ajax(options)};$.fn.load=function(url,data,success){if(!this.length)return this;var self=this,parts=url.split(/\s/),selector,options=parseArguments(url,data,success),callback=options.success;if(parts.length>1)options.url=parts[0],selector=parts[1];options.success=function(response){self.html(selector?$("<div>").html(response.replace(rscript,"")).find(selector):response);callback&&callback.apply(self,arguments)};$.ajax(options);return this};var escape=encodeURIComponent;function serialize(params,obj,traditional,scope){var type,array=$.isArray(obj),hash=$.isPlainObject(obj);$.each(obj,function(key,value){type=$.type(value);if(scope)key=traditional?scope:scope+"["+(hash||type=="object"||type=="array"?key:"")+"]";if(!scope&&array)params.add(value.name,value.value);else if(type=="array"||!traditional&&type=="object")serialize(params,value,traditional,key);else params.add(key,value)})}$.param=function(obj,traditional){var params=[];params.add=function(key,value){if($.isFunction(value))value=value();if(value==null)value="";this.push(escape(key)+"="+escape(value))};serialize(params,obj,traditional);return params.join("&").replace(/%20/g,"+")}})(Zepto);(function($){$.fn.serializeArray=function(){var name,type,result=[],add=function(value){if(value.forEach)return value.forEach(add);result.push({name:name,value:value})};if(this[0])$.each(this[0].elements,function(_,field){type=field.type,name=field.name;if(name&&field.nodeName.toLowerCase()!="fieldset"&&!field.disabled&&type!="submit"&&type!="reset"&&type!="button"&&type!="file"&&(type!="radio"&&type!="checkbox"||field.checked))add($(field).val())});return result};$.fn.serialize=function(){var result=[];this.serializeArray().forEach(function(elm){result.push(encodeURIComponent(elm.name)+"="+encodeURIComponent(elm.value))});return result.join("&")};$.fn.submit=function(callback){if(0 in arguments)this.bind("submit",callback);else if(this.length){var event=$.Event("submit");this.eq(0).trigger(event);if(!event.isDefaultPrevented())this.get(0).submit()}return this}})(Zepto);(function(){try{getComputedStyle(undefined)}catch(e){var nativeGetComputedStyle=getComputedStyle;window.getComputedStyle=function(element,pseudoElement){try{return nativeGetComputedStyle(element,pseudoElement)}catch(e){return null}}}})();return Zepto});(function(global,factory){typeof exports==="object"&&typeof module!=="undefined"?factory(exports):typeof define==="function"&&define.amd?define(["exports"],factory):factory(global.riot={})})(this,function(exports){"use strict";function $(selector,ctx){return(ctx||document).querySelector(selector)}var __TAGS_CACHE=[],__TAG_IMPL={},YIELD_TAG="yield",GLOBAL_MIXIN="__global_mixin",ATTRS_PREFIX="riot-",REF_DIRECTIVES=["ref","data-ref"],IS_DIRECTIVE="data-is",CONDITIONAL_DIRECTIVE="if",LOOP_DIRECTIVE="each",LOOP_NO_REORDER_DIRECTIVE="no-reorder",SHOW_DIRECTIVE="show",HIDE_DIRECTIVE="hide",KEY_DIRECTIVE="key",RIOT_EVENTS_KEY="__riot-events__",T_STRING="string",T_OBJECT="object",T_UNDEF="undefined",T_FUNCTION="function",XLINK_NS="http://www.w3.org/1999/xlink",SVG_NS="http://www.w3.org/2000/svg",XLINK_REGEX=/^xlink:(\w+)/,WIN=typeof window===T_UNDEF?undefined:window,RE_SPECIAL_TAGS=/^(?:t(?:body|head|foot|[rhd])|caption|col(?:group)?|opt(?:ion|group))$/,RE_SPECIAL_TAGS_NO_OPTION=/^(?:t(?:body|head|foot|[rhd])|caption|col(?:group)?)$/,RE_EVENTS_PREFIX=/^on/,RE_HTML_ATTRS=/([-\w]+) ?= ?(?:"([^"]*)|'([^']*)|({[^}]*}))/g,CASE_SENSITIVE_ATTRIBUTES={viewbox:"viewBox",preserveaspectratio:"preserveAspectRatio"},RE_BOOL_ATTRS=/^(?:disabled|checked|readonly|required|allowfullscreen|auto(?:focus|play)|compact|controls|default|formnovalidate|hidden|ismap|itemscope|loop|multiple|muted|no(?:resize|shade|validate|wrap)?|open|reversed|seamless|selected|sortable|truespeed|typemustmatch)$/,IE_VERSION=(WIN&&WIN.document||{}).documentMode|0;function makeElement(name){return name==="svg"?document.createElementNS(SVG_NS,name):document.createElement(name)}function setAttribute(dom,name,val){var xlink=XLINK_REGEX.exec(name);if(xlink&&xlink[1]){dom.setAttributeNS(XLINK_NS,xlink[1],val)}else{dom.setAttribute(name,val)}}var styleNode;var cssTextProp;var byName={};var needsInject=false;if(WIN){styleNode=function(){var newNode=makeElement("style");var userNode=$("style[type=riot]");setAttribute(newNode,"type","text/css");if(userNode){if(userNode.id){newNode.id=userNode.id}userNode.parentNode.replaceChild(newNode,userNode)}else{document.head.appendChild(newNode)}return newNode}();cssTextProp=styleNode.styleSheet}var styleManager={styleNode:styleNode,add:function add(css,name){byName[name]=css;needsInject=true},inject:function inject(){if(!WIN||!needsInject){return}needsInject=false;var style=Object.keys(byName).map(function(k){return byName[k]}).join("\n");if(cssTextProp){cssTextProp.cssText=style}else{styleNode.innerHTML=style}},remove:function remove(name){delete byName[name];needsInject=true}};var skipRegex=function(){var beforeReChars="[{(,;:?=|&!^~>%*/";var beforeReWords=["case","default","do","else","in","instanceof","prefix","return","typeof","void","yield"];var wordsLastChar=beforeReWords.reduce(function(s,w){return s+w.slice(-1)},"");var RE_REGEX=/^\/(?=[^*>/])[^[/\\]*(?:(?:\\.|\[(?:\\.|[^\]\\]*)*\])[^[\\/]*)*?\/[gimuy]*/;var RE_VN_CHAR=/[$\w]/;function prev(code,pos){while(--pos>=0&&/\s/.test(code[pos])){}return pos}function _skipRegex(code,start){var re=/.*/g;var pos=re.lastIndex=start++;var match=re.exec(code)[0].match(RE_REGEX);if(match){var next=pos+match[0].length;pos=prev(code,pos);var c=code[pos];if(pos<0||~beforeReChars.indexOf(c)){return next}if(c==="."){if(code[pos-1]==="."){start=next}}else if(c==="+"||c==="-"){if(code[--pos]!==c||(pos=prev(code,pos))<0||!RE_VN_CHAR.test(code[pos])){start=next}}else if(~wordsLastChar.indexOf(c)){var end=pos+1;while(--pos>=0&&RE_VN_CHAR.test(code[pos])){}if(~beforeReWords.indexOf(code.slice(pos+1,end))){start=next}}}return start}return _skipRegex}();var brackets=function(UNDEF){var REGLOB="g",R_MLCOMMS=/\/\*[^*]*\*+(?:[^*\/][^*]*\*+)*\//g,R_STRINGS=/"[^"\\]*(?:\\[\S\s][^"\\]*)*"|'[^'\\]*(?:\\[\S\s][^'\\]*)*'|`[^`\\]*(?:\\[\S\s][^`\\]*)*`/g,S_QBLOCKS=R_STRINGS.source+"|"+/(?:\breturn\s+|(?:[$\w\)\]]|\+\+|--)\s*(\/)(?![*\/]))/.source+"|"+/\/(?=[^*\/])[^[\/\\]*(?:(?:\[(?:\\.|[^\]\\]*)*\]|\\.)[^[\/\\]*)*?([^<]\/)[gim]*/.source,UNSUPPORTED=RegExp("[\\"+"x00-\\x1F<>a-zA-Z0-9'\",;\\\\]"),NEED_ESCAPE=/(?=[[\]()*+?.^$|])/g,S_QBLOCK2=R_STRINGS.source+"|"+/(\/)(?![*\/])/.source,FINDBRACES={"(":RegExp("([()])|"+S_QBLOCK2,REGLOB),"[":RegExp("([[\\]])|"+S_QBLOCK2,REGLOB),"{":RegExp("([{}])|"+S_QBLOCK2,REGLOB)},DEFAULT="{ }";var _pairs=["{","}","{","}",/{[^}]*}/,/\\([{}])/g,/\\({)|{/g,RegExp("\\\\(})|([[({])|(})|"+S_QBLOCK2,REGLOB),DEFAULT,/^\s*{\^?\s*([$\w]+)(?:\s*,\s*(\S+))?\s+in\s+(\S.*)\s*}/,/(^|[^\\]){=[\S\s]*?}/];var cachedBrackets=UNDEF,_regex,_cache=[],_settings;function _loopback(re){return re}function _rewrite(re,bp){if(!bp){bp=_cache}return new RegExp(re.source.replace(/{/g,bp[2]).replace(/}/g,bp[3]),re.global?REGLOB:"")}function _create(pair){if(pair===DEFAULT){return _pairs}var arr=pair.split(" ");if(arr.length!==2||UNSUPPORTED.test(pair)){throw new Error('Unsupported brackets "'+pair+'"')}arr=arr.concat(pair.replace(NEED_ESCAPE,"\\").split(" "));arr[4]=_rewrite(arr[1].length>1?/{[\S\s]*?}/:_pairs[4],arr);arr[5]=_rewrite(pair.length>3?/\\({|})/g:_pairs[5],arr);arr[6]=_rewrite(_pairs[6],arr);arr[7]=RegExp("\\\\("+arr[3]+")|([[({])|("+arr[3]+")|"+S_QBLOCK2,REGLOB);arr[8]=pair;return arr}function _brackets(reOrIdx){return reOrIdx instanceof RegExp?_regex(reOrIdx):_cache[reOrIdx]}_brackets.split=function split(str,tmpl,_bp){if(!_bp){_bp=_cache}var parts=[],match,isexpr,start,pos,re=_bp[6];var qblocks=[];var prevStr="";var mark,lastIndex;isexpr=start=re.lastIndex=0;while(match=re.exec(str)){lastIndex=re.lastIndex;pos=match.index;if(isexpr){if(match[2]){var ch=match[2];var rech=FINDBRACES[ch];var ix=1;rech.lastIndex=lastIndex;while(match=rech.exec(str)){if(match[1]){if(match[1]===ch){++ix}else if(!--ix){break}}else{rech.lastIndex=pushQBlock(match.index,rech.lastIndex,match[2])}}re.lastIndex=ix?str.length:rech.lastIndex;continue}if(!match[3]){re.lastIndex=pushQBlock(pos,lastIndex,match[4]);continue}}if(!match[1]){unescapeStr(str.slice(start,pos));start=re.lastIndex;re=_bp[6+(isexpr^=1)];re.lastIndex=start}}if(str&&start<str.length){unescapeStr(str.slice(start))}parts.qblocks=qblocks;return parts;function unescapeStr(s){if(prevStr){s=prevStr+s;prevStr=""}if(tmpl||isexpr){parts.push(s&&s.replace(_bp[5],"$1"))}else{parts.push(s)}}function pushQBlock(_pos,_lastIndex,slash){if(slash){_lastIndex=skipRegex(str,_pos)}if(tmpl&&_lastIndex>_pos+2){mark="⁗"+qblocks.length+"~";qblocks.push(str.slice(_pos,_lastIndex));prevStr+=str.slice(start,_pos)+mark;start=_lastIndex}return _lastIndex}};_brackets.hasExpr=function hasExpr(str){return _cache[4].test(str)};_brackets.loopKeys=function loopKeys(expr){var m=expr.match(_cache[9]);return m?{key:m[1],pos:m[2],val:_cache[0]+m[3].trim()+_cache[1]}:{val:expr.trim()}};_brackets.array=function array(pair){return pair?_create(pair):_cache};function _reset(pair){if((pair||(pair=DEFAULT))!==_cache[8]){_cache=_create(pair);_regex=pair===DEFAULT?_loopback:_rewrite;_cache[9]=_regex(_pairs[9])}cachedBrackets=pair}function _setSettings(o){var b;o=o||{};b=o.brackets;Object.defineProperty(o,"brackets",{set:_reset,get:function(){return cachedBrackets},enumerable:true});_settings=o;_reset(b)}Object.defineProperty(_brackets,"settings",{set:_setSettings,get:function(){return _settings}});_brackets.settings=typeof riot!=="undefined"&&riot.settings||{};_brackets.set=_reset;_brackets.skipRegex=skipRegex;_brackets.R_STRINGS=R_STRINGS;_brackets.R_MLCOMMS=R_MLCOMMS;_brackets.S_QBLOCKS=S_QBLOCKS;_brackets.S_QBLOCK2=S_QBLOCK2;return _brackets}();var tmpl=function(){var _cache={};function _tmpl(str,data){if(!str){return str}return(_cache[str]||(_cache[str]=_create(str))).call(data,_logErr.bind({data:data,tmpl:str}))}_tmpl.hasExpr=brackets.hasExpr;_tmpl.loopKeys=brackets.loopKeys;_tmpl.clearCache=function(){_cache={}};_tmpl.errorHandler=null;function _logErr(err,ctx){err.riotData={tagName:ctx&&ctx.__&&ctx.__.tagName,_riot_id:ctx&&ctx._riot_id};if(_tmpl.errorHandler){_tmpl.errorHandler(err)}else if(typeof console!=="undefined"&&typeof console.error==="function"){console.error(err.message);console.log("<%s> %s",err.riotData.tagName||"Unknown tag",this.tmpl);console.log(this.data)}}function _create(str){var expr=_getTmpl(str);if(expr.slice(0,11)!=="try{return "){expr="return "+expr}return new Function("E",expr+";")}var RE_DQUOTE=/\u2057/g;var RE_QBMARK=/\u2057(\d+)~/g;function _getTmpl(str){var parts=brackets.split(str.replace(RE_DQUOTE,'"'),1);var qstr=parts.qblocks;var expr;if(parts.length>2||parts[0]){var i,j,list=[];for(i=j=0;i<parts.length;++i){expr=parts[i];if(expr&&(expr=i&1?_parseExpr(expr,1,qstr):'"'+expr.replace(/\\/g,"\\\\").replace(/\r\n?|\n/g,"\\n").replace(/"/g,'\\"')+'"')){list[j++]=expr}}expr=j<2?list[0]:"["+list.join(",")+'].join("")'}else{expr=_parseExpr(parts[1],0,qstr)}if(qstr.length){expr=expr.replace(RE_QBMARK,function(_,pos){return qstr[pos].replace(/\r/g,"\\r").replace(/\n/g,"\\n")})}return expr}var RE_CSNAME=/^(?:(-?[_A-Za-z\xA0-\xFF][-\w\xA0-\xFF]*)|\u2057(\d+)~):/;var RE_BREND={"(":/[()]/g,"[":/[[\]]/g,"{":/[{}]/g};function _parseExpr(expr,asText,qstr){expr=expr.replace(/\s+/g," ").trim().replace(/\ ?([[\({},?\.:])\ ?/g,"$1");if(expr){var list=[],cnt=0,match;while(expr&&(match=expr.match(RE_CSNAME))&&!match.index){var key,jsb,re=/,|([[{(])|$/g;expr=RegExp.rightContext;key=match[2]?qstr[match[2]].slice(1,-1).trim().replace(/\s+/g," "):match[1];while(jsb=(match=re.exec(expr))[1]){skipBraces(jsb,re)}jsb=expr.slice(0,match.index);expr=RegExp.rightContext;list[cnt++]=_wrapExpr(jsb,1,key)}expr=!cnt?_wrapExpr(expr,asText):cnt>1?"["+list.join(",")+'].join(" ").trim()':list[0]}return expr;function skipBraces(ch,re){var mm,lv=1,ir=RE_BREND[ch];ir.lastIndex=re.lastIndex;while(mm=ir.exec(expr)){if(mm[0]===ch){++lv}else if(!--lv){break}}re.lastIndex=lv?expr.length:ir.lastIndex}}var JS_CONTEXT='"in this?this:'+(typeof window!=="object"?"global":"window")+").",JS_VARNAME=/[,{][\$\w]+(?=:)|(^ *|[^$\w\.{])(?!(?:typeof|true|false|null|undefined|in|instanceof|is(?:Finite|NaN)|void|NaN|new|Date|RegExp|Math)(?![$\w]))([$_A-Za-z][$\w]*)/g,JS_NOPROPS=/^(?=(\.[$\w]+))\1(?:[^.[(]|$)/;function _wrapExpr(expr,asText,key){var tb;expr=expr.replace(JS_VARNAME,function(match,p,mvar,pos,s){if(mvar){pos=tb?0:pos+match.length;if(mvar!=="this"&&mvar!=="global"&&mvar!=="window"){match=p+'("'+mvar+JS_CONTEXT+mvar;if(pos){tb=(s=s[pos])==="."||s==="("||s==="["}}else if(pos){tb=!JS_NOPROPS.test(s.slice(pos))}}return match});if(tb){expr="try{return "+expr+"}catch(e){E(e,this)}"}if(key){expr=(tb?"function(){"+expr+"}.call(this)":"("+expr+")")+'?"'+key+'":""'}else if(asText){expr="function(v){"+(tb?expr.replace("return ","v="):"v=("+expr+")")+';return v||v===0?v:""}.call(this)'}return expr}_tmpl.version=brackets.version="v3.0.8";return _tmpl}();var observable=function(el){el=el||{};var callbacks={},slice=Array.prototype.slice;Object.defineProperties(el,{on:{value:function(event,fn){if(typeof fn=="function"){(callbacks[event]=callbacks[event]||[]).push(fn)}return el},enumerable:false,writable:false,configurable:false},off:{value:function(event,fn){if(event=="*"&&!fn){callbacks={}}else{if(fn){var arr=callbacks[event];for(var i=0,cb;cb=arr&&arr[i];++i){if(cb==fn){arr.splice(i--,1)}}}else{delete callbacks[event]}}return el},enumerable:false,writable:false,configurable:false},one:{value:function(event,fn){function on(){el.off(event,on);fn.apply(el,arguments)}return el.on(event,on)},enumerable:false,writable:false,configurable:false},trigger:{value:function(event){var arguments$1=arguments;var arglen=arguments.length-1,args=new Array(arglen),fns,fn,i;for(i=0;i<arglen;i++){args[i]=arguments$1[i+1]}fns=slice.call(callbacks[event]||[],0);for(i=0;fn=fns[i];++i){fn.apply(el,args)}if(callbacks["*"]&&event!="*"){el.trigger.apply(el,["*",event].concat(args))}return el},enumerable:false,writable:false,configurable:false}});return el};function getPropDescriptor(o,k){return Object.getOwnPropertyDescriptor(o,k)}function isUndefined(value){return typeof value===T_UNDEF}function isWritable(obj,key){var descriptor=getPropDescriptor(obj,key);return isUndefined(obj[key])||descriptor&&descriptor.writable}function extend(src){var obj;var i=1;var args=arguments;var l=args.length;for(;i<l;i++){if(obj=args[i]){for(var key in obj){if(isWritable(src,key)){src[key]=obj[key]}}}}return src}function create(src){return Object.create(src)}var settings=extend(create(brackets.settings),{skipAnonymousTags:true,keepValueAttributes:false,autoUpdate:true});function $$(selector,ctx){return[].slice.call((ctx||document).querySelectorAll(selector))}function createDOMPlaceholder(){return document.createTextNode("")}function toggleVisibility(dom,show){dom.style.display=show?"":"none";dom.hidden=show?false:true}function getAttribute(dom,name){return dom.getAttribute(name)}function removeAttribute(dom,name){dom.removeAttribute(name)}function setInnerHTML(container,html,isSvg){if(isSvg){var node=container.ownerDocument.importNode((new DOMParser).parseFromString('<svg xmlns="'+SVG_NS+'">'+html+"</svg>","application/xml").documentElement,true);container.appendChild(node)}else{container.innerHTML=html}}function walkAttributes(html,fn){if(!html){return}var m;while(m=RE_HTML_ATTRS.exec(html)){fn(m[1].toLowerCase(),m[2]||m[3]||m[4])}}function createFragment(){return document.createDocumentFragment()}function safeInsert(root,curr,next){root.insertBefore(curr,next.parentNode&&next)}function styleObjectToString(style){return Object.keys(style).reduce(function(acc,prop){return acc+" "+prop+": "+style[prop]+";"},"")}function walkNodes(dom,fn,context){if(dom){var res=fn(dom,context);var next;if(res===false){return}dom=dom.firstChild;while(dom){next=dom.nextSibling;walkNodes(dom,fn,res);dom=next}}}var dom=Object.freeze({$$:$$,$:$,createDOMPlaceholder:createDOMPlaceholder,mkEl:makeElement,setAttr:setAttribute,toggleVisibility:toggleVisibility,getAttr:getAttribute,remAttr:removeAttribute,setInnerHTML:setInnerHTML,walkAttrs:walkAttributes,createFrag:createFragment,safeInsert:safeInsert,styleObjectToString:styleObjectToString,walkNodes:walkNodes});function isNil(value){return isUndefined(value)||value===null}function isBlank(value){return isNil(value)||value===""}function isFunction(value){return typeof value===T_FUNCTION}function isObject(value){return value&&typeof value===T_OBJECT}function isSvg(el){var owner=el.ownerSVGElement;return!!owner||owner===null}function isArray(value){return Array.isArray(value)||value instanceof Array}function isBoolAttr(value){return RE_BOOL_ATTRS.test(value)}function isString(value){return typeof value===T_STRING}var check=Object.freeze({isBlank:isBlank,isFunction:isFunction,isObject:isObject,isSvg:isSvg,isWritable:isWritable,isArray:isArray,isBoolAttr:isBoolAttr,isNil:isNil,isString:isString,isUndefined:isUndefined});function contains(array,item){return array.indexOf(item)!==-1}function each(list,fn){var len=list?list.length:0;var i=0;for(;i<len;i++){fn(list[i],i)}return list}function startsWith(str,value){return str.slice(0,value.length)===value}var uid=function uid(){var i=-1;return function(){return++i}}();function define(el,key,value,options){Object.defineProperty(el,key,extend({value:value,enumerable:false,writable:false,configurable:true},options));return el}function toCamel(str){return str.replace(/-(\w)/g,function(_,c){return c.toUpperCase()})}function warn(message){if(console&&console.warn){console.warn(message)}}var misc=Object.freeze({contains:contains,each:each,getPropDescriptor:getPropDescriptor,startsWith:startsWith,uid:uid,defineProperty:define,objectCreate:create,extend:extend,toCamel:toCamel,warn:warn});function arrayishAdd(obj,key,value,ensureArray,index){var dest=obj[key];var isArr=isArray(dest);var hasIndex=!isUndefined(index);if(dest&&dest===value){return}if(!dest&&ensureArray){obj[key]=[value]}else if(!dest){obj[key]=value}else{if(isArr){var oldIndex=dest.indexOf(value);if(oldIndex===index){return}if(oldIndex!==-1){dest.splice(oldIndex,1)}if(hasIndex){dest.splice(index,0,value)}else{dest.push(value)}}else{obj[key]=[dest,value]}}}function get(dom){return dom.tagName&&__TAG_IMPL[getAttribute(dom,IS_DIRECTIVE)||getAttribute(dom,IS_DIRECTIVE)||dom.tagName.toLowerCase()]}function getName(dom,skipDataIs){var child=get(dom);var namedTag=!skipDataIs&&getAttribute(dom,IS_DIRECTIVE);return namedTag&&!tmpl.hasExpr(namedTag)?namedTag:child?child.name:dom.tagName.toLowerCase()}function inheritParentProps(){if(this.parent){return extend(create(this),this.parent)}return this}var reHasYield=/<yield\b/i,reYieldAll=/<yield\s*(?:\/>|>([\S\s]*?)<\/yield\s*>|>)/gi,reYieldSrc=/<yield\s+to=['"]([^'">]*)['"]\s*>([\S\s]*?)<\/yield\s*>/gi,reYieldDest=/<yield\s+from=['"]?([-\w]+)['"]?\s*(?:\/>|>([\S\s]*?)<\/yield\s*>)/gi,rootEls={tr:"tbody",th:"tr",td:"tr",col:"colgroup"},tblTags=IE_VERSION&&IE_VERSION<10?RE_SPECIAL_TAGS:RE_SPECIAL_TAGS_NO_OPTION,GENERIC="div",SVG="svg";function specialTags(el,tmpl,tagName){var select=tagName[0]==="o",parent=select?"select>":"table>";el.innerHTML="<"+parent+tmpl.trim()+"</"+parent;parent=el.firstChild;if(select){parent.selectedIndex=-1}else{var tname=rootEls[tagName];if(tname&&parent.childElementCount===1){parent=$(tname,parent)}}return parent}function replaceYield(tmpl,html){if(!reHasYield.test(tmpl)){return tmpl}var src={};html=html&&html.replace(reYieldSrc,function(_,ref,text){src[ref]=src[ref]||text;return""}).trim();return tmpl.replace(reYieldDest,function(_,ref,def){return src[ref]||def||""}).replace(reYieldAll,function(_,def){return html||def||""})}function mkdom(tmpl,html,isSvg){var match=tmpl&&tmpl.match(/^\s*<([-\w]+)/);var tagName=match&&match[1].toLowerCase();var el=makeElement(isSvg?SVG:GENERIC);tmpl=replaceYield(tmpl,html);if(tblTags.test(tagName)){el=specialTags(el,tmpl,tagName)}else{setInnerHTML(el,tmpl,isSvg)}return el}var EVENT_ATTR_RE=/^on/;function isEventAttribute(attribute){return EVENT_ATTR_RE.test(attribute)}function getImmediateCustomParent(tag){var ptag=tag;while(ptag.__.isAnonymous){if(!ptag.parent){break}ptag=ptag.parent}return ptag}function handleEvent(dom,handler,e){var ptag=this.__.parent;var item=this.__.item;if(!item){while(ptag&&!item){item=ptag.__.item;ptag=ptag.__.parent}}if(isWritable(e,"currentTarget")){e.currentTarget=dom}if(isWritable(e,"target")){e.target=e.srcElement}if(isWritable(e,"which")){e.which=e.charCode||e.keyCode}e.item=item;handler.call(this,e);if(!settings.autoUpdate){return}if(!e.preventUpdate){var p=getImmediateCustomParent(this);if(p.isMounted){p.update()}}}function setEventHandler(name,handler,dom,tag){var eventName;var cb=handleEvent.bind(tag,dom,handler);dom[name]=null;eventName=name.replace(RE_EVENTS_PREFIX,"");if(!contains(tag.__.listeners,dom)){tag.__.listeners.push(dom)}if(!dom[RIOT_EVENTS_KEY]){dom[RIOT_EVENTS_KEY]={}}if(dom[RIOT_EVENTS_KEY][name]){dom.removeEventListener(eventName,dom[RIOT_EVENTS_KEY][name])}dom[RIOT_EVENTS_KEY][name]=cb;dom.addEventListener(eventName,cb,false)}function initChild(child,opts,innerHTML,parent){var tag=createTag(child,opts,innerHTML);var tagName=opts.tagName||getName(opts.root,true);var ptag=getImmediateCustomParent(parent);define(tag,"parent",ptag);tag.__.parent=parent;arrayishAdd(ptag.tags,tagName,tag);if(ptag!==parent){arrayishAdd(parent.tags,tagName,tag)}return tag}function arrayishRemove(obj,key,value,ensureArray){if(isArray(obj[key])){var index=obj[key].indexOf(value);if(index!==-1){obj[key].splice(index,1)}if(!obj[key].length){delete obj[key]}else if(obj[key].length===1&&!ensureArray){obj[key]=obj[key][0]}}else if(obj[key]===value){delete obj[key]}}function makeVirtual(src,target){var this$1=this;var head=createDOMPlaceholder();var tail=createDOMPlaceholder();var frag=createFragment();var sib;var el;this.root.insertBefore(head,this.root.firstChild);this.root.appendChild(tail);this.__.head=el=head;this.__.tail=tail;while(el){sib=el.nextSibling;frag.appendChild(el);this$1.__.virts.push(el);el=sib}if(target){src.insertBefore(frag,target.__.head)}else{src.appendChild(frag)}}function makeReplaceVirtual(tag,ref){if(!ref.parentNode){return}var frag=createFragment();makeVirtual.call(tag,frag);ref.parentNode.replaceChild(frag,ref)}function updateDataIs(expr,parent,tagName){var tag=expr.tag||expr.dom._tag;var ref;var ref$1=tag?tag.__:{};var head=ref$1.head;var isVirtual=expr.dom.tagName==="VIRTUAL";if(tag&&expr.tagName===tagName){tag.update();return}if(tag){if(isVirtual){ref=createDOMPlaceholder();head.parentNode.insertBefore(ref,head)}tag.unmount(true)}if(!isString(tagName)){return}expr.impl=__TAG_IMPL[tagName];if(!expr.impl){return}expr.tag=tag=initChild(expr.impl,{root:expr.dom,parent:parent,tagName:tagName},expr.dom.innerHTML,parent);each(expr.attrs,function(a){return setAttribute(tag.root,a.name,a.value)});expr.tagName=tagName;tag.mount();if(isVirtual){makeReplaceVirtual(tag,ref||tag.root)}parent.__.onUnmount=function(){var delName=tag.opts.dataIs;arrayishRemove(tag.parent.tags,delName,tag);arrayishRemove(tag.__.parent.tags,delName,tag);tag.unmount()}}function normalizeAttrName(attrName){if(!attrName){return null}attrName=attrName.replace(ATTRS_PREFIX,"");if(CASE_SENSITIVE_ATTRIBUTES[attrName]){attrName=CASE_SENSITIVE_ATTRIBUTES[attrName]}return attrName}function updateExpression(expr){if(this.root&&getAttribute(this.root,"virtualized")){return}var dom=expr.dom;var attrName=normalizeAttrName(expr.attr);var isToggle=contains([SHOW_DIRECTIVE,HIDE_DIRECTIVE],attrName);var isVirtual=expr.root&&expr.root.tagName==="VIRTUAL";var ref=this.__;var isAnonymous=ref.isAnonymous;var parent=dom&&(expr.parent||dom.parentNode);var keepValueAttributes=settings.keepValueAttributes;var isStyleAttr=attrName==="style";var isClassAttr=attrName==="class";var isValueAttr=attrName==="value";var value;if(expr._riot_id){if(expr.__.wasCreated){expr.update()}else{expr.mount();if(isVirtual){makeReplaceVirtual(expr,expr.root)}}return}if(expr.update){return expr.update()}var context=isToggle&&!isAnonymous?inheritParentProps.call(this):this;value=tmpl(expr.expr,context);var hasValue=!isBlank(value);var isObj=isObject(value);if(isObj){if(isClassAttr){value=tmpl(JSON.stringify(value),this)}else if(isStyleAttr){value=styleObjectToString(value)}}if(expr.attr&&(!expr.wasParsedOnce||value===false||!hasValue&&(!isValueAttr||isValueAttr&&!keepValueAttributes))){removeAttribute(dom,getAttribute(dom,expr.attr)?expr.attr:attrName)}if(expr.bool){value=value?attrName:false}if(expr.isRtag){return updateDataIs(expr,this,value)}if(expr.wasParsedOnce&&expr.value===value){return}expr.value=value;expr.wasParsedOnce=true;if(isObj&&!isClassAttr&&!isStyleAttr&&!isToggle){return}if(!hasValue){value=""}if(!attrName){value+="";if(parent){expr.parent=parent;if(parent.tagName==="TEXTAREA"){parent.value=value;if(!IE_VERSION){dom.nodeValue=value}}else{dom.nodeValue=value}}return}switch(true){case isFunction(value):if(isEventAttribute(attrName)){setEventHandler(attrName,value,dom,this)}break;case isToggle:toggleVisibility(dom,attrName===HIDE_DIRECTIVE?!value:value);break;default:if(expr.bool){dom[attrName]=value}if(isValueAttr&&dom.value!==value){dom.value=value}else if(hasValue&&value!==false){setAttribute(dom,attrName,value)}if(isStyleAttr&&dom.hidden){toggleVisibility(dom,false)}}}function update(expressions){each(expressions,updateExpression.bind(this))}function updateOpts(isLoop,parent,isAnonymous,opts,instAttrs){if(isLoop&&isAnonymous){return}var ctx=isLoop?inheritParentProps.call(this):parent||this;each(instAttrs,function(attr){if(attr.expr){updateExpression.call(ctx,attr.expr)}opts[toCamel(attr.name).replace(ATTRS_PREFIX,"")]=attr.expr?attr.expr.value:attr.value})}function componentUpdate(tag,data,expressions){var __=tag.__;var nextOpts={};var canTrigger=tag.isMounted&&!__.skipAnonymous;if(__.isAnonymous&&__.parent){extend(tag,__.parent)}extend(tag,data);updateOpts.apply(tag,[__.isLoop,__.parent,__.isAnonymous,nextOpts,__.instAttrs]);if(canTrigger&&tag.isMounted&&isFunction(tag.shouldUpdate)&&!tag.shouldUpdate(data,nextOpts)){return tag}extend(tag.opts,nextOpts);if(canTrigger){tag.trigger("update",data)}update.call(tag,expressions);if(canTrigger){tag.trigger("updated")}return tag}function query(tags){if(!tags){var keys=Object.keys(__TAG_IMPL);return keys+query(keys)}return tags.filter(function(t){return!/[^-\w]/.test(t)}).reduce(function(list,t){var name=t.trim().toLowerCase();return list+",["+IS_DIRECTIVE+'="'+name+'"]'},"")}function Tag(el,opts){var ref=this;var name=ref.name;var tmpl=ref.tmpl;var css=ref.css;var attrs=ref.attrs;var onCreate=ref.onCreate;if(!__TAG_IMPL[name]){tag(name,tmpl,css,attrs,onCreate);__TAG_IMPL[name].class=this.constructor}mount$1(el,name,opts,this);if(css){styleManager.inject()}return this}function tag(name,tmpl,css,attrs,fn){if(isFunction(attrs)){fn=attrs;if(/^[\w-]+\s?=/.test(css)){attrs=css;css=""}else{attrs=""}}if(css){if(isFunction(css)){fn=css}else{styleManager.add(css,name)}}name=name.toLowerCase();__TAG_IMPL[name]={name:name,tmpl:tmpl,attrs:attrs,fn:fn};return name}function tag2(name,tmpl,css,attrs,fn){if(css){styleManager.add(css,name)}__TAG_IMPL[name]={name:name,tmpl:tmpl,attrs:attrs,fn:fn};return name}function mount(selector,tagName,opts){var tags=[];var elem,allTags;function pushTagsTo(root){if(root.tagName){var riotTag=getAttribute(root,IS_DIRECTIVE),tag;if(tagName&&riotTag!==tagName){riotTag=tagName;setAttribute(root,IS_DIRECTIVE,tagName)}tag=mount$1(root,riotTag||root.tagName.toLowerCase(),isFunction(opts)?opts():opts);if(tag){tags.push(tag)}}else if(root.length){each(root,pushTagsTo)}}styleManager.inject();if(isObject(tagName)||isFunction(tagName)){opts=tagName;tagName=0}if(isString(selector)){selector=selector==="*"?allTags=query():selector+query(selector.split(/, */));elem=selector?$$(selector):[]}else{elem=selector}if(tagName==="*"){tagName=allTags||query();if(elem.tagName){elem=$$(tagName,elem)}else{var nodeList=[];each(elem,function(_el){return nodeList.push($$(tagName,_el))});elem=nodeList}tagName=0}pushTagsTo(elem);return tags}var mixins={};var globals=mixins[GLOBAL_MIXIN]={};var mixins_id=0;function mixin(name,mix,g){if(isObject(name)){mixin("__"+mixins_id+++"__",name,true);return}var store=g?globals:mixins;if(!mix){if(isUndefined(store[name])){throw new Error("Unregistered mixin: "+name)}return store[name]}store[name]=isFunction(mix)?extend(mix.prototype,store[name]||{})&&mix:extend(store[name]||{},mix)}function update$1(){return each(__TAGS_CACHE,function(tag){return tag.update()})}function unregister(name){styleManager.remove(name);return delete __TAG_IMPL[name]}var version="v3.13.2";var core=Object.freeze({Tag:Tag,tag:tag,tag2:tag2,mount:mount,mixin:mixin,update:update$1,unregister:unregister,version:version});function componentMixin(tag$$1){var mixins=[],len=arguments.length-1;while(len-- >0)mixins[len]=arguments[len+1];each(mixins,function(mix){var instance;var obj;var props=[];var propsBlacklist=["init","__proto__"];mix=isString(mix)?mixin(mix):mix;if(isFunction(mix)){instance=new mix}else{instance=mix}var proto=Object.getPrototypeOf(instance);do{props=props.concat(Object.getOwnPropertyNames(obj||instance))}while(obj=Object.getPrototypeOf(obj||instance));each(props,function(key){if(!contains(propsBlacklist,key)){var descriptor=getPropDescriptor(instance,key)||getPropDescriptor(proto,key);var hasGetterSetter=descriptor&&(descriptor.get||descriptor.set);if(!tag$$1.hasOwnProperty(key)&&hasGetterSetter){Object.defineProperty(tag$$1,key,descriptor)}else{tag$$1[key]=isFunction(instance[key])?instance[key].bind(tag$$1):instance[key]}}});if(instance.init){instance.init.bind(tag$$1)(tag$$1.opts)}});return tag$$1}function moveChild(tagName,newPos){var parent=this.parent;var tags;if(!parent){return}tags=parent.tags[tagName];if(isArray(tags)){tags.splice(newPos,0,tags.splice(tags.indexOf(this),1)[0])}else{arrayishAdd(parent.tags,tagName,this)}}function moveVirtual(src,target){var this$1=this;var el=this.__.head;var sib;var frag=createFragment();while(el){sib=el.nextSibling;frag.appendChild(el);el=sib;if(el===this$1.__.tail){frag.appendChild(el);src.insertBefore(frag,target.__.head);break}}}function mkitem(expr,key,val){var item={};item[expr.key]=key;if(expr.pos){item[expr.pos]=val}return item}function unmountRedundant(items,tags,filteredItemsCount){var i=tags.length;var j=items.length-filteredItemsCount;while(i>j){i--;remove.apply(tags[i],[tags,i])}}function remove(tags,i){tags.splice(i,1);this.unmount();arrayishRemove(this.parent,this,this.__.tagName,true)}function moveNestedTags(i){var this$1=this;each(Object.keys(this.tags),function(tagName){moveChild.apply(this$1.tags[tagName],[tagName,i])})}function move(root,nextTag,isVirtual){if(isVirtual){moveVirtual.apply(this,[root,nextTag])}else{safeInsert(root,this.root,nextTag.root)}}function insert(root,nextTag,isVirtual){if(isVirtual){makeVirtual.apply(this,[root,nextTag])}else{safeInsert(root,this.root,nextTag.root)}}function append(root,isVirtual){if(isVirtual){makeVirtual.call(this,root)}else{root.appendChild(this.root)}}function getItemId(keyAttr,originalItem,keyedItem,hasKeyAttrExpr){if(keyAttr){return hasKeyAttrExpr?tmpl(keyAttr,keyedItem):originalItem[keyAttr]}return originalItem}function _each(dom,parent,expr){var mustReorder=typeof getAttribute(dom,LOOP_NO_REORDER_DIRECTIVE)!==T_STRING||removeAttribute(dom,LOOP_NO_REORDER_DIRECTIVE);var keyAttr=getAttribute(dom,KEY_DIRECTIVE);var hasKeyAttrExpr=keyAttr?tmpl.hasExpr(keyAttr):false;var tagName=getName(dom);var impl=__TAG_IMPL[tagName];var parentNode=dom.parentNode;var placeholder=createDOMPlaceholder();var child=get(dom);var ifExpr=getAttribute(dom,CONDITIONAL_DIRECTIVE);var tags=[];var isLoop=true;var innerHTML=dom.innerHTML;var isAnonymous=!__TAG_IMPL[tagName];var isVirtual=dom.tagName==="VIRTUAL";var oldItems=[];removeAttribute(dom,LOOP_DIRECTIVE);removeAttribute(dom,KEY_DIRECTIVE);expr=tmpl.loopKeys(expr);expr.isLoop=true;if(ifExpr){removeAttribute(dom,CONDITIONAL_DIRECTIVE)}parentNode.insertBefore(placeholder,dom);parentNode.removeChild(dom);expr.update=function updateEach(){expr.value=tmpl(expr.val,parent);var items=expr.value;var frag=createFragment();var isObject=!isArray(items)&&!isString(items);var root=placeholder.parentNode;var tmpItems=[];var hasKeys=isObject&&!!items;if(!root){return}if(isObject){items=items?Object.keys(items).map(function(key){return mkitem(expr,items[key],key)}):[]}var filteredItemsCount=0;each(items,function(_item,index){var i=index-filteredItemsCount;var item=!hasKeys&&expr.key?mkitem(expr,_item,index):_item;if(ifExpr&&!tmpl(ifExpr,extend(create(parent),item))){filteredItemsCount++;return}var itemId=getItemId(keyAttr,_item,item,hasKeyAttrExpr);var doReorder=!isObject&&mustReorder&&typeof _item===T_OBJECT||keyAttr;var oldPos=oldItems.indexOf(itemId);var isNew=oldPos===-1;var pos=!isNew&&doReorder?oldPos:i;var tag=tags[pos];var mustAppend=i>=oldItems.length;var mustCreate=doReorder&&isNew||!doReorder&&!tag||!tags[i];if(mustCreate){tag=createTag(impl,{parent:parent,isLoop:isLoop,isAnonymous:isAnonymous,tagName:tagName,root:dom.cloneNode(isAnonymous),item:item,index:i},innerHTML);tag.mount();if(mustAppend){append.apply(tag,[frag||root,isVirtual])}else{insert.apply(tag,[root,tags[i],isVirtual])}if(!mustAppend){oldItems.splice(i,0,item)}tags.splice(i,0,tag);if(child){arrayishAdd(parent.tags,tagName,tag,true)}}else if(pos!==i&&doReorder){if(keyAttr||contains(items,oldItems[pos])){move.apply(tag,[root,tags[i],isVirtual]);tags.splice(i,0,tags.splice(pos,1)[0]);oldItems.splice(i,0,oldItems.splice(pos,1)[0])}if(expr.pos){tag[expr.pos]=i}if(!child&&tag.tags){moveNestedTags.call(tag,i)}}extend(tag.__,{item:item,index:i,parent:parent});tmpItems[i]=itemId;if(!mustCreate){tag.update(item)}});unmountRedundant(items,tags,filteredItemsCount);oldItems=tmpItems.slice();root.insertBefore(frag,placeholder)};expr.unmount=function(){each(tags,function(t){t.unmount()})};return expr}var RefExpr={init:function init(dom,parent,attrName,attrValue){this.dom=dom;this.attr=attrName;this.rawValue=attrValue;this.parent=parent;this.hasExp=tmpl.hasExpr(attrValue);return this},update:function update(){var old=this.value;var customParent=this.parent&&getImmediateCustomParent(this.parent);var tagOrDom=this.dom.__ref||this.tag||this.dom;this.value=this.hasExp?tmpl(this.rawValue,this.parent):this.rawValue;if(!isBlank(old)&&customParent){arrayishRemove(customParent.refs,old,tagOrDom)}if(!isBlank(this.value)&&isString(this.value)){if(customParent){arrayishAdd(customParent.refs,this.value,tagOrDom,null,this.parent.__.index)}if(this.value!==old){setAttribute(this.dom,this.attr,this.value)}}else{removeAttribute(this.dom,this.attr)}if(!this.dom.__ref){this.dom.__ref=tagOrDom}},unmount:function unmount(){var tagOrDom=this.tag||this.dom;var customParent=this.parent&&getImmediateCustomParent(this.parent);if(!isBlank(this.value)&&customParent){arrayishRemove(customParent.refs,this.value,tagOrDom)}}};function createRefDirective(dom,tag,attrName,attrValue){return create(RefExpr).init(dom,tag,attrName,attrValue)}function unmountAll(expressions){each(expressions,function(expr){if(expr.unmount){expr.unmount(true)}else if(expr.tagName){expr.tag.unmount(true)}else if(expr.unmount){expr.unmount()}})}var IfExpr={init:function init(dom,tag,expr){removeAttribute(dom,CONDITIONAL_DIRECTIVE);extend(this,{tag:tag,expr:expr,stub:createDOMPlaceholder(),pristine:dom});var p=dom.parentNode;p.insertBefore(this.stub,dom);p.removeChild(dom);return this},update:function update$$1(){this.value=tmpl(this.expr,this.tag);if(!this.stub.parentNode){return}if(this.value&&!this.current){this.current=this.pristine.cloneNode(true);this.stub.parentNode.insertBefore(this.current,this.stub);this.expressions=parseExpressions.apply(this.tag,[this.current,true])}else if(!this.value&&this.current){this.unmount();this.current=null;this.expressions=[]}if(this.value){update.call(this.tag,this.expressions)}},unmount:function unmount(){if(this.current){if(this.current._tag){this.current._tag.unmount()}else if(this.current.parentNode){this.current.parentNode.removeChild(this.current)}}unmountAll(this.expressions||[])}};function createIfDirective(dom,tag,attr){return create(IfExpr).init(dom,tag,attr)}function parseExpressions(root,mustIncludeRoot){var this$1=this;var expressions=[];walkNodes(root,function(dom){var type=dom.nodeType;var attr;var tagImpl;if(!mustIncludeRoot&&dom===root){return}if(type===3&&dom.parentNode.tagName!=="STYLE"&&tmpl.hasExpr(dom.nodeValue)){expressions.push({dom:dom,expr:dom.nodeValue})}if(type!==1){return}var isVirtual=dom.tagName==="VIRTUAL";if(attr=getAttribute(dom,LOOP_DIRECTIVE)){if(isVirtual){setAttribute(dom,"loopVirtual",true)}expressions.push(_each(dom,this$1,attr));return false}if(attr=getAttribute(dom,CONDITIONAL_DIRECTIVE)){expressions.push(createIfDirective(dom,this$1,attr));return false}if(attr=getAttribute(dom,IS_DIRECTIVE)){if(tmpl.hasExpr(attr)){expressions.push({isRtag:true,expr:attr,dom:dom,attrs:[].slice.call(dom.attributes)});return false}}tagImpl=get(dom);if(isVirtual){if(getAttribute(dom,"virtualized")){dom.parentElement.removeChild(dom)}if(!tagImpl&&!getAttribute(dom,"virtualized")&&!getAttribute(dom,"loopVirtual")){tagImpl={tmpl:dom.outerHTML}}}if(tagImpl&&(dom!==root||mustIncludeRoot)){var hasIsDirective=getAttribute(dom,IS_DIRECTIVE);if(isVirtual&&!hasIsDirective){setAttribute(dom,"virtualized",true);var tag=createTag({tmpl:dom.outerHTML},{root:dom,parent:this$1},dom.innerHTML);expressions.push(tag)}else{if(hasIsDirective&&isVirtual){warn("Virtual tags shouldn't be used together with the \""+IS_DIRECTIVE+'" attribute - https://github.com/riot/riot/issues/2511')}expressions.push(initChild(tagImpl,{root:dom,parent:this$1},dom.innerHTML,this$1));return false}}parseAttributes.apply(this$1,[dom,dom.attributes,function(attr,expr){if(!expr){return}expressions.push(expr)}])});return expressions}function parseAttributes(dom,attrs,fn){var this$1=this;each(attrs,function(attr){if(!attr){return false}var name=attr.name;var bool=isBoolAttr(name);var expr;if(contains(REF_DIRECTIVES,name)&&dom.tagName.toLowerCase()!==YIELD_TAG){expr=createRefDirective(dom,this$1,name,attr.value)}else if(tmpl.hasExpr(attr.value)){expr={dom:dom,expr:attr.value,attr:name,bool:bool}}fn(attr,expr)})}function setMountState(value){var ref=this.__;var isAnonymous=ref.isAnonymous;var skipAnonymous=ref.skipAnonymous;define(this,"isMounted",value);if(!isAnonymous||!skipAnonymous){if(value){this.trigger("mount")}else{this.trigger("unmount");this.off("*");this.__.wasCreated=false}}}function componentMount(tag$$1,dom,expressions,opts){var __=tag$$1.__;var root=__.root;root._tag=tag$$1;parseAttributes.apply(__.parent,[root,root.attributes,function(attr,expr){if(!__.isAnonymous&&RefExpr.isPrototypeOf(expr)){expr.tag=tag$$1}attr.expr=expr;__.instAttrs.push(attr)}]);walkAttributes(__.impl.attrs,function(k,v){__.implAttrs.push({name:k,value:v})});parseAttributes.apply(tag$$1,[root,__.implAttrs,function(attr,expr){if(expr){expressions.push(expr)}else{setAttribute(root,attr.name,attr.value)}}]);updateOpts.apply(tag$$1,[__.isLoop,__.parent,__.isAnonymous,opts,__.instAttrs]);var globalMixin=mixin(GLOBAL_MIXIN);if(globalMixin&&!__.skipAnonymous){for(var i in globalMixin){if(globalMixin.hasOwnProperty(i)){tag$$1.mixin(globalMixin[i])}}}if(__.impl.fn){__.impl.fn.call(tag$$1,opts)}if(!__.skipAnonymous){tag$$1.trigger("before-mount")}each(parseExpressions.apply(tag$$1,[dom,__.isAnonymous]),function(e){return expressions.push(e)});tag$$1.update(__.item);if(!__.isAnonymous&&!__.isInline){while(dom.firstChild){root.appendChild(dom.firstChild)}}define(tag$$1,"root",root);if(!__.skipAnonymous&&tag$$1.parent){var p=getImmediateCustomParent(tag$$1.parent);p.one(!p.isMounted?"mount":"updated",function(){setMountState.call(tag$$1,true)})}else{setMountState.call(tag$$1,true)}tag$$1.__.wasCreated=true;return tag$$1}function tagUnmount(tag,mustKeepRoot,expressions){var __=tag.__;var root=__.root;var tagIndex=__TAGS_CACHE.indexOf(tag);var p=root.parentNode;if(!__.skipAnonymous){tag.trigger("before-unmount")}walkAttributes(__.impl.attrs,function(name){if(startsWith(name,ATTRS_PREFIX)){name=name.slice(ATTRS_PREFIX.length)}removeAttribute(root,name)});tag.__.listeners.forEach(function(dom){Object.keys(dom[RIOT_EVENTS_KEY]).forEach(function(eventName){dom.removeEventListener(eventName,dom[RIOT_EVENTS_KEY][eventName])})});if(tagIndex!==-1){__TAGS_CACHE.splice(tagIndex,1)}if(__.parent&&!__.isAnonymous){var ptag=getImmediateCustomParent(__.parent);if(__.isVirtual){Object.keys(tag.tags).forEach(function(tagName){return arrayishRemove(ptag.tags,tagName,tag.tags[tagName])})}else{arrayishRemove(ptag.tags,__.tagName,tag)}}if(tag.__.virts){each(tag.__.virts,function(v){if(v.parentNode){v.parentNode.removeChild(v)}})}unmountAll(expressions);each(__.instAttrs,function(a){return a.expr&&a.expr.unmount&&a.expr.unmount()});if(mustKeepRoot){setInnerHTML(root,"")}else if(p){p.removeChild(root)}if(__.onUnmount){__.onUnmount()}if(!tag.isMounted){setMountState.call(tag,true)}setMountState.call(tag,false);delete root._tag;return tag}function createTag(impl,conf,innerHTML){if(impl===void 0)impl={};if(conf===void 0)conf={};var tag=conf.context||{};var opts=conf.opts||{};var parent=conf.parent;var isLoop=conf.isLoop;var isAnonymous=!!conf.isAnonymous;var skipAnonymous=settings.skipAnonymousTags&&isAnonymous;var item=conf.item;var index=conf.index;var instAttrs=[];var implAttrs=[];var tmpl=impl.tmpl;var expressions=[];var root=conf.root;var tagName=conf.tagName||getName(root);var isVirtual=tagName==="virtual";var isInline=!isVirtual&&!tmpl;var dom;if(isInline||isLoop&&isAnonymous){dom=root}else{if(!isVirtual){root.innerHTML=""}dom=mkdom(tmpl,innerHTML,isSvg(root))}if(!skipAnonymous){observable(tag)}if(impl.name&&root._tag){root._tag.unmount(true)}define(tag,"__",{impl:impl,root:root,skipAnonymous:skipAnonymous,implAttrs:implAttrs,isAnonymous:isAnonymous,instAttrs:instAttrs,innerHTML:innerHTML,tagName:tagName,index:index,isLoop:isLoop,isInline:isInline,item:item,parent:parent,listeners:[],virts:[],wasCreated:false,tail:null,head:null});return[["isMounted",false],["_riot_id",uid()],["root",root],["opts",opts,{writable:true,enumerable:true}],["parent",parent||null],["tags",{}],["refs",{}],["update",function(data){return componentUpdate(tag,data,expressions)}],["mixin",function(){var mixins=[],len=arguments.length;while(len--)mixins[len]=arguments[len];return componentMixin.apply(void 0,[tag].concat(mixins))}],["mount",function(){return componentMount(tag,dom,expressions,opts)}],["unmount",function(mustKeepRoot){return tagUnmount(tag,mustKeepRoot,expressions)}]].reduce(function(acc,ref){var key=ref[0];var value=ref[1];var opts=ref[2];define(tag,key,value,opts);return acc},extend(tag,item))}function mount$1(root,tagName,opts,ctx){var impl=__TAG_IMPL[tagName];var implClass=__TAG_IMPL[tagName].class;var context=ctx||(implClass?create(implClass.prototype):{});var innerHTML=root._innerHTML=root._innerHTML||root.innerHTML;var conf=extend({root:root,opts:opts,context:context},{parent:opts?opts.parent:null});var tag;if(impl&&root){tag=createTag(impl,conf,innerHTML)}if(tag&&tag.mount){tag.mount(true);if(!contains(__TAGS_CACHE,tag)){__TAGS_CACHE.push(tag)}}return tag}var tags=Object.freeze({arrayishAdd:arrayishAdd,getTagName:getName,inheritParentProps:inheritParentProps,mountTo:mount$1,selectTags:query,arrayishRemove:arrayishRemove,getTag:get,initChildTag:initChild,moveChildTag:moveChild,makeReplaceVirtual:makeReplaceVirtual,getImmediateCustomParentTag:getImmediateCustomParent,makeVirtual:makeVirtual,moveVirtual:moveVirtual,unmountAll:unmountAll,createIfDirective:createIfDirective,createRefDirective:createRefDirective});var settings$1=settings;var util={tmpl:tmpl,brackets:brackets,styleManager:styleManager,vdom:__TAGS_CACHE,styleNode:styleManager.styleNode,dom:dom,check:check,misc:misc,tags:tags};var Tag$1=Tag;var tag$1=tag;var tag2$1=tag2;var mount$2=mount;var mixin$1=mixin;var update$2=update$1;var unregister$1=unregister;var version$1=version;var observable$1=observable;var riot$1=extend({},core,{observable:observable,settings:settings$1,util:util});exports.settings=settings$1;exports.util=util;exports.Tag=Tag$1;exports.tag=tag$1;exports.tag2=tag2$1;exports.mount=mount$2;exports.mixin=mixin$1;exports.update=update$2;exports.unregister=unregister$1;exports.version=version$1;exports.observable=observable$1;exports.default=riot$1;Object.defineProperty(exports,"__esModule",{value:true})});$.extend($.ajaxSettings,{dataType:"json",contentType:"application/json"});window.wApp={bus:riot.observable(),data:{}};wApp.routing={query:function(params){var k,qs,result,v;if(params){result={};$.extend(result,wApp.routing.query(),params);qs=[];for(k in result){v=result[k];if(result[k]!==null&&result[k]!==""){qs.push(k+"="+v)}}return riot.route(self.routing.path()+"?"+qs.join("&"))}else{return wApp.routing.parts()["hash_query"]||{}}},path:function(new_path){if(new_path){return riot.route(new_path)}else{return wApp.routing.parts()["hash_path"]}},parts:function(){var cs,h,hash_query_string,j,kv,l,len,len1,pair,ref,ref1,result;if(!wApp.routing.parts_cache){h=document.location.href;cs=h.match(/^(https?):\/\/([^\/]+)([^?#]+)?(?:\?([^#]+))?(?:#(.*))?$/);result={href:h,scheme:cs[1],host:cs[2],path:cs[3],query_string:cs[4],query:{},hash:cs[5],hash_query:{}};if(result.query_string){ref=result.query_string.split("&");for(j=0,len=ref.length;j<len;j++){pair=ref[j];kv=pair.split("=");result.query[kv[0]]=kv[1]}}if(result.hash){result.hash_path=result.hash.split("?")[0];if(hash_query_string=result.hash.split("?")[1]){ref1=hash_query_string.split("&");for(l=0,len1=ref1.length;l<len1;l++){pair=ref1[l];kv=pair.split("=");result.hash_query[kv[0]]=kv[1]}}}wApp.routing.parts_cache=result}return wApp.routing.parts_cache},setup:function(){if(!wApp.routing.route){wApp.routing.route=riot.route.create();riot.route.base("#/");wApp.routing.route("..",function(){var old_parts;old_parts=wApp.routing.parts();if(document.location.href!==old_parts["href"]){wApp.routing.parts_cache=null;wApp.bus.trigger("routing:href",wApp.routing.parts());if(old_parts["hash_path"]!==wApp.routing.path()){return wApp.bus.trigger("routing:path",wApp.routing.parts())}else{return wApp.bus.trigger("routing:query",wApp.routing.parts())}}});riot.route.start(true);return wApp.bus.trigger("routing:path",wApp.routing.parts())}}};wApp.utils={shorten:function(str,n){if(n==null){n=15}if(str&&str.length>n){return str.substr(0,n-1)+"&hellip;"}else{return str}},in_groups_of:function(per_row,array,dummy){var current,i,j,len,result;if(dummy==null){dummy=null}result=[];current=[];for(j=0,len=array.length;j<len;j++){i=array[j];if(current.length===per_row){result.push(current);current=[]}current.push(i)}if(current.length>0){if(dummy){while(current.length<per_row){current.push(dummy)}}result.push(current)}return result},to_integer:function(value){if($.isNumeric(value)){return parseInt(value)}else{return value}}};riot.tag2("kor-application",'<div class="container"> <a href="#/login">login</a> <a href="#/welcome">welcome</a> <a href="#/search">search</a> <a href="#/logout">logout</a> </div> <kor-js-extensions></kor-js-extensions> <kor-router></kor-router> <kor-notifications></kor-notifications> <div id="page-container" class="container"> <kor-page class="kor-appear-animation"></kor-page> </div>',"","",function(opts){var mount_page,self;self=this;window.kor={url:self.opts.baseUrl||"",bus:riot.observable(),load_session:function(){return $.ajax({type:"get",url:kor.url+"/api/1.0/info",success:function(data){kor.info=data;return kor.bus.trigger("data.info")}})},login:function(username,password){console.log(arguments);return $.ajax({type:"post",url:kor.url+"/login",data:JSON.stringify({username:username,password:password}),success:function(data){return kor.load_session()}})},logout:function(){return $.ajax({type:"delete",url:kor.url+"/logout",success:function(){return kor.load_session()}})}};riot.mixin({kor:kor});$.extend($.ajaxSettings,{contentType:"application/json",dataType:"json",error:function(request){console.log(request);return kor.bus.trigger("notify",JSON.parse(request.response))}});mount_page=function(tag){var element;if(self.mounted_page!==tag){if(self.page_tag){self.page_tag.unmount(true)}element=$(self.root).find("kor-page");self.page_tag=riot.mount(element[0],tag)[0];element.detach();$(self["page-container"]).append(element);return self.mounted_page=tag}};self.on("mount",function(){mount_page("kor-loading");return kor.load_session()});kor.bus.on("page.welcome",function(){return mount_page("kor-welcome")});kor.bus.on("page.login",function(){return mount_page("kor-login")});kor.bus.on("page.entity",function(){return mount_page("kor-entity")});kor.bus.on("page.search",function(){return mount_page("kor-search")})});riot.tag2("kor-loading","<span>... loading ...</span>","","",function(opts){});riot.tag2("kor-login",'<div class="row"> <div class="col-md-3 col-md-offset-4"> <div class="panel panel-default"> <div class="panel-heading">Login</div> <div class="panel-body"> <form class="form" method="POST" onsubmit="{submit}"> <div class="control-group"> <label for="kor-login-form-username">Username</label> <input type="text" name="username" class="form-control" id="kor-login-form-username"> </div> <div class="control-group"> <label for="kor-login-form-password">Password</label> <input type="password" name="password" class="form-control" id="kor-login-form-password"> </div> <div class="form-group text-right"></div> <input type="submit" class="form-control btn btn-default"> </div> </form> </div> </div> </div> </div>',"","",function(opts){var self;self=this;self.on("mount",function(){return $(self.root).find("input")[0].focus()});self.submit=function(event){event.preventDefault();return kor.login($(self["kor-login-form-username"]).val(),$(self["kor-login-form-password"]).val())}});riot.tag2("kor-notifications",'<ul> <li each="{data in messages}" class="bg-warning {kor-fade-animation: data.remove}" onanimationend="{parent.animend}"> <i class="glyphicon glyphicon-exclamation-sign"></i> {data.message} </li> </ul>',"","",function(opts){var fading,self;self=this;self.messages=[];self.history=[];self.animend=function(event){var i;i=self.messages.indexOf(event.item.data);self.history.push(self.messages[i]);self.messages.splice(i,1);return self.update()};fading=function(data){self.messages.push(data);self.update();return setTimeout(function(){data.remove=true;return self.update()},5e3)};kor.bus.on("notify",function(data){var type;type=data.type||"default";if(type==="default"){fading(data)}return self.update()})});riot.tag2("kor-search",'<h1>Search</h1> <form class="form"> <div class="row"> <div class="col-md-3"> <div class="form-group"> <input type="text" name="terms" placeholder="fulltext search ..." class="form-control" id="kor-search-form-terms" onchange="{form_to_url}" riot-value="{params.terms}"> </div> </div> </div> <div class="row"> <div class="col-md-12 collections"> <button class="btn btn-default btn-xs allnone" onclick="{allnone}">all/none</button> <div class="checkbox-inline" each="{collection in collections}"> <label> <input type="checkbox" riot-value="{collection.id}" checked="{parent.is_collection_checked(collection)}" onchange="{parent.form_to_url}"> {collection.name} </label> </div> </div> </div> <div class="row"> <div class="col-md-12 kinds"> <button class="btn btn-default btn-xs allnone" onclick="{allnone}">all/none</button> <div class="checkbox-inline" each="{kind in kinds}"> <label> <input type="checkbox" riot-value="{kind.id}" checked="{parent.is_kind_checked(kind)}" onchange="{parent.form_to_url}"> {kind.plural_name} </label> </div> </div> </div> <div class="row"> <div class="col-md-3 kinds" each="{field in fields}"> <div class="form-group"> <input type="text" name="{field.name}" placeholder="{field.search_label}" class="kor-dataset-field form-control" id="kor-search-form-dataset-{field.name}" onchange="{parent.form_to_url}" riot-value="{parent.params.dataset[field.name]}"> </div> </div> </div> </form>',"","",function(opts){var self;self=this;window.x=this;self.params={};self.on("mount",function(){$.ajax({type:"get",url:kor.url+"/kinds",success:function(data){self.kinds=data;return self.update()}});$.ajax({type:"get",url:kor.url+"/collections",success:function(data){self.collections=data;return self.update()}});self.url_to_params();return self.update()});self.kor.bus.on("query.data",function(){self.url_to_params();return self.update()});self.is_kind_checked=function(kind){return self.params["kind_ids"]===void 0||self.params["kind_ids"].indexOf(kind.id)>-1};self.is_collection_checked=function(collection){return self.params["collection_ids"]===void 0||self.params["collection_ids"].indexOf(collection.id)>-1};self.url_to_params=function(){self.params=self.kor.routing.state.get();self.load_fields();return self.update()};self.form_to_url=function(){var cb,collection_ids,dataset,i,j,kind_ids,len,len1,ref,ref1;kind_ids=[];ref=$(self.root).find(".kinds input[type=checkbox]:checked");for(i=0,len=ref.length;i<len;i++){cb=ref[i];kind_ids.push(parseInt($(cb).val()))}collection_ids=[];ref1=$(self.root).find(".collections input[type=checkbox]:checked");for(j=0,len1=ref1.length;j<len1;j++){cb=ref1[j];collection_ids.push(parseInt($(cb).val()))}dataset={};return self.kor.routing.state.update({terms:$(x.root).find("[name=terms]").val(),collection_ids:collection_ids,kind_ids:kind_ids})};self.load_fields=function(){var id;if(self.params.kind_ids.length===1){id=self.params.kind_ids[0];return $.ajax({type:"get",url:kor.url+"/kinds/"+id+"/fields",success:function(data){console.log(data);self.fields=data;return self.update()}})}else{return self.fields=[]}};self.allnone=function(event){var box,boxes,i,len;event.preventDefault();boxes=$(event.target).parent().find("input[type=checkbox]");for(i=0,len=boxes.length;i<len;i++){box=boxes[i];if(!$(box).is(":checked")){boxes.prop("checked",true);self.form_to_url();return}}boxes.prop("checked",null);return self.form_to_url()}});riot.tag2("kor-welcome","<h2>Welcome</h2>","","",function(opts){});riot.tag2("kor-entity",'<div class="auth" if="{!authorized}"> <strong>Info</strong> <p> It seems you are not allowed to see this content. Please <a href="{login_url()}">login</a> to the kor installation first. </p> </div> <a href="{url()}" if="{authorized}" target="_blank"> <img if="{data.medium}" riot-src="{image_url()}"> <div if="{!data.medium}"> <h3>{data.display_name}</h3> <em if="{include(\'kind\')}"> {data.kind_name} <span show="{data.subtype}">({data.subtype})</span> </em> </div> </a>',"","class=\"{'kor-style': opts.korStyle, 'kor': opts.korStyle}\"",function(opts){var self;self=this;self.authorized=true;self.on("mount",function(){var base;if(self.opts.id){base=$("script[kor-url]").attr("kor-url")||"";return $.ajax({type:"get",url:base+"/entities/"+self.opts.id,data:{include:"all"},dataType:"json",beforeSend:function(xhr){return xhr.withCredentials=true},success:function(data){self.data=data;return self.update()},error:function(request){self.data={};if(request.status===403){self.authorized=false;return self.update()}}})}else{return raise("this widget requires an id")}});self.login_url=function(){var base,return_to;base=$("script[kor-url]").attr("kor-url")||"";return_to=document.location.href;return base+"/login?return_to="+return_to};self.image_size=function(){return self.opts.korImageSize||"preview"};self.image_url=function(){var base,size;base=$("script[kor-url]").attr("kor-url")||"";size=self.image_size();return""+base+self.data.medium.url[size]};self.include=function(what){var includes;includes=(self.opts.korInclude||"").split(/\s+/);return includes.indexOf(what)!==-1};self.url=function(){var base;base=$("[kor-url]").attr("kor-url")||"";return base+"/blaze#/entities/"+self.data.id};self.human_size=function(){var size;size=self.data.medium.file_size/1024/1024;return Math.floor(size*100)/100}});riot.tag2("w-app",'<w-style></w-style> <div class="w-content"></div> <w-modal></w-modal> <w-messaging></w-messaging>',"","",function(opts){var self;self=this;self.on("mount",function(){return wApp.routing.setup()});wApp.bus.on("routing:path",function(parts){var opts,tag;opts={};tag=function(){switch(parts["hash_path"]){case"/some/path":opts["some"]=parts["hash_query"].value;return"some-tag";default:return"some-default-tag"}}();riot.mount($(".w-content")[0],tag,opts);return window.scrollTo(0,0)})});riot.tag2("w-messaging",'<div each="{message in messages}" class="message {\'error\': error(message), \'notice\': notice(message)}"> <i show="{notice(message)}" class="fa fa-warning"></i> <i show="{error(message)}" class="fa fa-info-circle"></i> {message.content} </div>',"","",function(opts){var self;self=this;$(document).on("ajaxComplete",function(event,request,options){var data,e,type;try{data=JSON.parse(request.response);if(data.message){type=request.status>=200&&request.status<300?"notice":"error";return wApp.bus.trigger("message",type,data.message)}}catch(error){e=error;return console.log(e)}});self.on("mount",function(){return self.messages=[]});wApp.bus.on("message",function(type,message){self.messages.push({type:type,content:message});window.setTimeout(self.drop,self.opts.duration||5e3);return self.update()});self.drop=function(){self.messages.shift();return self.update()};self.error=function(message){return message.type==="error"};self.notice=function(message){return message.type==="notice"}});riot.tag2("w-modal",'<div name="receiver"></div>',"",'style="display: none"',function(opts){var self;self=this;self.active=false;wApp.bus.on("modal",function(tag,opts){if(opts==null){opts={}}opts.modal=self;riot.mount(self.receiver,tag,opts);$(self.root).show();return self.active=true});$(document).on("keydown",function(event){if(event.key==="Escape"){return self.trigger("close")}});self.on("mount",function(){return $(self.root).on("click",function(event){if(event.target===self.root){return self.trigger("close")}})});self.on("close",function(){if(self.active){$(self.root).hide();return self.active=false}})});riot.tag2("w-style","",'@font-face { font-family: \'FontAwesome\'; src: url("../fonts/fontawesome-webfont.eot?v=4.7.0"); src: url("../fonts/fontawesome-webfont.eot?#iefix&v=4.7.0") format("embedded-opentype"), url("../fonts/fontawesome-webfont.woff2?v=4.7.0") format("woff2"), url("../fonts/fontawesome-webfont.woff?v=4.7.0") format("woff"), url("../fonts/fontawesome-webfont.ttf?v=4.7.0") format("truetype"), url("../fonts/fontawesome-webfont.svg?v=4.7.0#fontawesomeregular") format("svg"); font-weight: normal; font-style: normal; } w-style .fa,[data-is="w-style"] .fa{ display: inline-block; font: normal normal normal 14px/1 FontAwesome; font-size: inherit; text-rendering: auto; -webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale; } w-style .fa-lg,[data-is="w-style"] .fa-lg{ font-size: 1.33333333em; line-height: .75em; vertical-align: -15%; } w-style .fa-2x,[data-is="w-style"] .fa-2x{ font-size: 2em; } w-style .fa-3x,[data-is="w-style"] .fa-3x{ font-size: 3em; } w-style .fa-4x,[data-is="w-style"] .fa-4x{ font-size: 4em; } w-style .fa-5x,[data-is="w-style"] .fa-5x{ font-size: 5em; } w-style .fa-fw,[data-is="w-style"] .fa-fw{ width: 1.28571429em; text-align: center; } w-style .fa-ul,[data-is="w-style"] .fa-ul{ padding-left: 0; margin-left: 2.14285714em; list-style-type: none; } w-style .fa-ul > li,[data-is="w-style"] .fa-ul > li{ position: relative; } w-style .fa-li,[data-is="w-style"] .fa-li{ position: absolute; left: -2.14285714em; width: 2.14285714em; top: .14285714em; text-align: center; } w-style .fa-li.fa-lg,[data-is="w-style"] .fa-li.fa-lg{ left: -1.85714286em; } w-style .fa-border,[data-is="w-style"] .fa-border{ padding: .2em .25em .15em; border: solid .08em #eee; border-radius: .1em; } w-style .fa-pull-left,[data-is="w-style"] .fa-pull-left{ float: left; } w-style .fa-pull-right,[data-is="w-style"] .fa-pull-right{ float: right; } w-style .fa.fa-pull-left,[data-is="w-style"] .fa.fa-pull-left{ margin-right: .3em; } w-style .fa.fa-pull-right,[data-is="w-style"] .fa.fa-pull-right{ margin-left: .3em; } w-style .pull-right,[data-is="w-style"] .pull-right{ float: right; } w-style .pull-left,[data-is="w-style"] .pull-left{ float: left; } w-style .fa.pull-left,[data-is="w-style"] .fa.pull-left{ margin-right: .3em; } w-style .fa.pull-right,[data-is="w-style"] .fa.pull-right{ margin-left: .3em; } w-style .fa-spin,[data-is="w-style"] .fa-spin{ -webkit-animation: fa-spin 2s infinite linear; animation: fa-spin 2s infinite linear; } w-style .fa-pulse,[data-is="w-style"] .fa-pulse{ -webkit-animation: fa-spin 1s infinite steps(8); animation: fa-spin 1s infinite steps(8); } @-webkit-keyframes fa-spin { 0% { -webkit-transform: rotate(0deg); transform: rotate(0deg); } 100% { -webkit-transform: rotate(359deg); transform: rotate(359deg); } } @keyframes fa-spin { 0% { -webkit-transform: rotate(0deg); transform: rotate(0deg); } 100% { -webkit-transform: rotate(359deg); transform: rotate(359deg); } } w-style .fa-rotate-90,[data-is="w-style"] .fa-rotate-90{ -ms-filter: "progid:DXImageTransform.Microsoft.BasicImage(rotation=1)"; -webkit-transform: rotate(90deg); -ms-transform: rotate(90deg); transform: rotate(90deg); } w-style .fa-rotate-180,[data-is="w-style"] .fa-rotate-180{ -ms-filter: "progid:DXImageTransform.Microsoft.BasicImage(rotation=2)"; -webkit-transform: rotate(180deg); -ms-transform: rotate(180deg); transform: rotate(180deg); } w-style .fa-rotate-270,[data-is="w-style"] .fa-rotate-270{ -ms-filter: "progid:DXImageTransform.Microsoft.BasicImage(rotation=3)"; -webkit-transform: rotate(270deg); -ms-transform: rotate(270deg); transform: rotate(270deg); } w-style .fa-flip-horizontal,[data-is="w-style"] .fa-flip-horizontal{ -ms-filter: "progid:DXImageTransform.Microsoft.BasicImage(rotation=0, mirror=1)"; -webkit-transform: scale(-1, 1); -ms-transform: scale(-1, 1); transform: scale(-1, 1); } w-style .fa-flip-vertical,[data-is="w-style"] .fa-flip-vertical{ -ms-filter: "progid:DXImageTransform.Microsoft.BasicImage(rotation=2, mirror=1)"; -webkit-transform: scale(1, -1); -ms-transform: scale(1, -1); transform: scale(1, -1); } w-style :root .fa-rotate-90,[data-is="w-style"] :root .fa-rotate-90,w-style :root .fa-rotate-180,[data-is="w-style"] :root .fa-rotate-180,w-style :root .fa-rotate-270,[data-is="w-style"] :root .fa-rotate-270,w-style :root .fa-flip-horizontal,[data-is="w-style"] :root .fa-flip-horizontal,w-style :root .fa-flip-vertical,[data-is="w-style"] :root .fa-flip-vertical{ filter: none; } w-style .fa-stack,[data-is="w-style"] .fa-stack{ position: relative; display: inline-block; width: 2em; height: 2em; line-height: 2em; vertical-align: middle; } w-style .fa-stack-1x,[data-is="w-style"] .fa-stack-1x,w-style .fa-stack-2x,[data-is="w-style"] .fa-stack-2x{ position: absolute; left: 0; width: 100%; text-align: center; } w-style .fa-stack-1x,[data-is="w-style"] .fa-stack-1x{ line-height: inherit; } w-style .fa-stack-2x,[data-is="w-style"] .fa-stack-2x{ font-size: 2em; } w-style .fa-inverse,[data-is="w-style"] .fa-inverse{ color: #fff; } w-style .fa-glass:before,[data-is="w-style"] .fa-glass:before{ content: "\\f000"; } w-style .fa-music:before,[data-is="w-style"] .fa-music:before{ content: "\\f001"; } w-style .fa-search:before,[data-is="w-style"] .fa-search:before{ content: "\\f002"; } w-style .fa-envelope-o:before,[data-is="w-style"] .fa-envelope-o:before{ content: "\\f003"; } w-style .fa-heart:before,[data-is="w-style"] .fa-heart:before{ content: "\\f004"; } w-style .fa-star:before,[data-is="w-style"] .fa-star:before{ content: "\\f005"; } w-style .fa-star-o:before,[data-is="w-style"] .fa-star-o:before{ content: "\\f006"; } w-style .fa-user:before,[data-is="w-style"] .fa-user:before{ content: "\\f007"; } w-style .fa-film:before,[data-is="w-style"] .fa-film:before{ content: "\\f008"; } w-style .fa-th-large:before,[data-is="w-style"] .fa-th-large:before{ content: "\\f009"; } w-style .fa-th:before,[data-is="w-style"] .fa-th:before{ content: "\\f00a"; } w-style .fa-th-list:before,[data-is="w-style"] .fa-th-list:before{ content: "\\f00b"; } w-style .fa-check:before,[data-is="w-style"] .fa-check:before{ content: "\\f00c"; } w-style .fa-remove:before,[data-is="w-style"] .fa-remove:before,w-style .fa-close:before,[data-is="w-style"] .fa-close:before,w-style .fa-times:before,[data-is="w-style"] .fa-times:before{ content: "\\f00d"; } w-style .fa-search-plus:before,[data-is="w-style"] .fa-search-plus:before{ content: "\\f00e"; } w-style .fa-search-minus:before,[data-is="w-style"] .fa-search-minus:before{ content: "\\f010"; } w-style .fa-power-off:before,[data-is="w-style"] .fa-power-off:before{ content: "\\f011"; } w-style .fa-signal:before,[data-is="w-style"] .fa-signal:before{ content: "\\f012"; } w-style .fa-gear:before,[data-is="w-style"] .fa-gear:before,w-style .fa-cog:before,[data-is="w-style"] .fa-cog:before{ content: "\\f013"; } w-style .fa-trash-o:before,[data-is="w-style"] .fa-trash-o:before{ content: "\\f014"; } w-style .fa-home:before,[data-is="w-style"] .fa-home:before{ content: "\\f015"; } w-style .fa-file-o:before,[data-is="w-style"] .fa-file-o:before{ content: "\\f016"; } w-style .fa-clock-o:before,[data-is="w-style"] .fa-clock-o:before{ content: "\\f017"; } w-style .fa-road:before,[data-is="w-style"] .fa-road:before{ content: "\\f018"; } w-style .fa-download:before,[data-is="w-style"] .fa-download:before{ content: "\\f019"; } w-style .fa-arrow-circle-o-down:before,[data-is="w-style"] .fa-arrow-circle-o-down:before{ content: "\\f01a"; } w-style .fa-arrow-circle-o-up:before,[data-is="w-style"] .fa-arrow-circle-o-up:before{ content: "\\f01b"; } w-style .fa-inbox:before,[data-is="w-style"] .fa-inbox:before{ content: "\\f01c"; } w-style .fa-play-circle-o:before,[data-is="w-style"] .fa-play-circle-o:before{ content: "\\f01d"; } w-style .fa-rotate-right:before,[data-is="w-style"] .fa-rotate-right:before,w-style .fa-repeat:before,[data-is="w-style"] .fa-repeat:before{ content: "\\f01e"; } w-style .fa-refresh:before,[data-is="w-style"] .fa-refresh:before{ content: "\\f021"; } w-style .fa-list-alt:before,[data-is="w-style"] .fa-list-alt:before{ content: "\\f022"; } w-style .fa-lock:before,[data-is="w-style"] .fa-lock:before{ content: "\\f023"; } w-style .fa-flag:before,[data-is="w-style"] .fa-flag:before{ content: "\\f024"; } w-style .fa-headphones:before,[data-is="w-style"] .fa-headphones:before{ content: "\\f025"; } w-style .fa-volume-off:before,[data-is="w-style"] .fa-volume-off:before{ content: "\\f026"; } w-style .fa-volume-down:before,[data-is="w-style"] .fa-volume-down:before{ content: "\\f027"; } w-style .fa-volume-up:before,[data-is="w-style"] .fa-volume-up:before{ content: "\\f028"; } w-style .fa-qrcode:before,[data-is="w-style"] .fa-qrcode:before{ content: "\\f029"; } w-style .fa-barcode:before,[data-is="w-style"] .fa-barcode:before{ content: "\\f02a"; } w-style .fa-tag:before,[data-is="w-style"] .fa-tag:before{ content: "\\f02b"; } w-style .fa-tags:before,[data-is="w-style"] .fa-tags:before{ content: "\\f02c"; } w-style .fa-book:before,[data-is="w-style"] .fa-book:before{ content: "\\f02d"; } w-style .fa-bookmark:before,[data-is="w-style"] .fa-bookmark:before{ content: "\\f02e"; } w-style .fa-print:before,[data-is="w-style"] .fa-print:before{ content: "\\f02f"; } w-style .fa-camera:before,[data-is="w-style"] .fa-camera:before{ content: "\\f030"; } w-style .fa-font:before,[data-is="w-style"] .fa-font:before{ content: "\\f031"; } w-style .fa-bold:before,[data-is="w-style"] .fa-bold:before{ content: "\\f032"; } w-style .fa-italic:before,[data-is="w-style"] .fa-italic:before{ content: "\\f033"; } w-style .fa-text-height:before,[data-is="w-style"] .fa-text-height:before{ content: "\\f034"; } w-style .fa-text-width:before,[data-is="w-style"] .fa-text-width:before{ content: "\\f035"; } w-style .fa-align-left:before,[data-is="w-style"] .fa-align-left:before{ content: "\\f036"; } w-style .fa-align-center:before,[data-is="w-style"] .fa-align-center:before{ content: "\\f037"; } w-style .fa-align-right:before,[data-is="w-style"] .fa-align-right:before{ content: "\\f038"; } w-style .fa-align-justify:before,[data-is="w-style"] .fa-align-justify:before{ content: "\\f039"; } w-style .fa-list:before,[data-is="w-style"] .fa-list:before{ content: "\\f03a"; } w-style .fa-dedent:before,[data-is="w-style"] .fa-dedent:before,w-style .fa-outdent:before,[data-is="w-style"] .fa-outdent:before{ content: "\\f03b"; } w-style .fa-indent:before,[data-is="w-style"] .fa-indent:before{ content: "\\f03c"; } w-style .fa-video-camera:before,[data-is="w-style"] .fa-video-camera:before{ content: "\\f03d"; } w-style .fa-photo:before,[data-is="w-style"] .fa-photo:before,w-style .fa-image:before,[data-is="w-style"] .fa-image:before,w-style .fa-picture-o:before,[data-is="w-style"] .fa-picture-o:before{ content: "\\f03e"; } w-style .fa-pencil:before,[data-is="w-style"] .fa-pencil:before{ content: "\\f040"; } w-style .fa-map-marker:before,[data-is="w-style"] .fa-map-marker:before{ content: "\\f041"; } w-style .fa-adjust:before,[data-is="w-style"] .fa-adjust:before{ content: "\\f042"; } w-style .fa-tint:before,[data-is="w-style"] .fa-tint:before{ content: "\\f043"; } w-style .fa-edit:before,[data-is="w-style"] .fa-edit:before,w-style .fa-pencil-square-o:before,[data-is="w-style"] .fa-pencil-square-o:before{ content: "\\f044"; } w-style .fa-share-square-o:before,[data-is="w-style"] .fa-share-square-o:before{ content: "\\f045"; } w-style .fa-check-square-o:before,[data-is="w-style"] .fa-check-square-o:before{ content: "\\f046"; } w-style .fa-arrows:before,[data-is="w-style"] .fa-arrows:before{ content: "\\f047"; } w-style .fa-step-backward:before,[data-is="w-style"] .fa-step-backward:before{ content: "\\f048"; } w-style .fa-fast-backward:before,[data-is="w-style"] .fa-fast-backward:before{ content: "\\f049"; } w-style .fa-backward:before,[data-is="w-style"] .fa-backward:before{ content: "\\f04a"; } w-style .fa-play:before,[data-is="w-style"] .fa-play:before{ content: "\\f04b"; } w-style .fa-pause:before,[data-is="w-style"] .fa-pause:before{ content: "\\f04c"; } w-style .fa-stop:before,[data-is="w-style"] .fa-stop:before{ content: "\\f04d"; } w-style .fa-forward:before,[data-is="w-style"] .fa-forward:before{ content: "\\f04e"; } w-style .fa-fast-forward:before,[data-is="w-style"] .fa-fast-forward:before{ content: "\\f050"; } w-style .fa-step-forward:before,[data-is="w-style"] .fa-step-forward:before{ content: "\\f051"; } w-style .fa-eject:before,[data-is="w-style"] .fa-eject:before{ content: "\\f052"; } w-style .fa-chevron-left:before,[data-is="w-style"] .fa-chevron-left:before{ content: "\\f053"; } w-style .fa-chevron-right:before,[data-is="w-style"] .fa-chevron-right:before{ content: "\\f054"; } w-style .fa-plus-circle:before,[data-is="w-style"] .fa-plus-circle:before{ content: "\\f055"; } w-style .fa-minus-circle:before,[data-is="w-style"] .fa-minus-circle:before{ content: "\\f056"; } w-style .fa-times-circle:before,[data-is="w-style"] .fa-times-circle:before{ content: "\\f057"; } w-style .fa-check-circle:before,[data-is="w-style"] .fa-check-circle:before{ content: "\\f058"; } w-style .fa-question-circle:before,[data-is="w-style"] .fa-question-circle:before{ content: "\\f059"; } w-style .fa-info-circle:before,[data-is="w-style"] .fa-info-circle:before{ content: "\\f05a"; } w-style .fa-crosshairs:before,[data-is="w-style"] .fa-crosshairs:before{ content: "\\f05b"; } w-style .fa-times-circle-o:before,[data-is="w-style"] .fa-times-circle-o:before{ content: "\\f05c"; } w-style .fa-check-circle-o:before,[data-is="w-style"] .fa-check-circle-o:before{ content: "\\f05d"; } w-style .fa-ban:before,[data-is="w-style"] .fa-ban:before{ content: "\\f05e"; } w-style .fa-arrow-left:before,[data-is="w-style"] .fa-arrow-left:before{ content: "\\f060"; } w-style .fa-arrow-right:before,[data-is="w-style"] .fa-arrow-right:before{ content: "\\f061"; } w-style .fa-arrow-up:before,[data-is="w-style"] .fa-arrow-up:before{ content: "\\f062"; } w-style .fa-arrow-down:before,[data-is="w-style"] .fa-arrow-down:before{ content: "\\f063"; } w-style .fa-mail-forward:before,[data-is="w-style"] .fa-mail-forward:before,w-style .fa-share:before,[data-is="w-style"] .fa-share:before{ content: "\\f064"; } w-style .fa-expand:before,[data-is="w-style"] .fa-expand:before{ content: "\\f065"; } w-style .fa-compress:before,[data-is="w-style"] .fa-compress:before{ content: "\\f066"; } w-style .fa-plus:before,[data-is="w-style"] .fa-plus:before{ content: "\\f067"; } w-style .fa-minus:before,[data-is="w-style"] .fa-minus:before{ content: "\\f068"; } w-style .fa-asterisk:before,[data-is="w-style"] .fa-asterisk:before{ content: "\\f069"; } w-style .fa-exclamation-circle:before,[data-is="w-style"] .fa-exclamation-circle:before{ content: "\\f06a"; } w-style .fa-gift:before,[data-is="w-style"] .fa-gift:before{ content: "\\f06b"; } w-style .fa-leaf:before,[data-is="w-style"] .fa-leaf:before{ content: "\\f06c"; } w-style .fa-fire:before,[data-is="w-style"] .fa-fire:before{ content: "\\f06d"; } w-style .fa-eye:before,[data-is="w-style"] .fa-eye:before{ content: "\\f06e"; } w-style .fa-eye-slash:before,[data-is="w-style"] .fa-eye-slash:before{ content: "\\f070"; } w-style .fa-warning:before,[data-is="w-style"] .fa-warning:before,w-style .fa-exclamation-triangle:before,[data-is="w-style"] .fa-exclamation-triangle:before{ content: "\\f071"; } w-style .fa-plane:before,[data-is="w-style"] .fa-plane:before{ content: "\\f072"; } w-style .fa-calendar:before,[data-is="w-style"] .fa-calendar:before{ content: "\\f073"; } w-style .fa-random:before,[data-is="w-style"] .fa-random:before{ content: "\\f074"; } w-style .fa-comment:before,[data-is="w-style"] .fa-comment:before{ content: "\\f075"; } w-style .fa-magnet:before,[data-is="w-style"] .fa-magnet:before{ content: "\\f076"; } w-style .fa-chevron-up:before,[data-is="w-style"] .fa-chevron-up:before{ content: "\\f077"; } w-style .fa-chevron-down:before,[data-is="w-style"] .fa-chevron-down:before{ content: "\\f078"; } w-style .fa-retweet:before,[data-is="w-style"] .fa-retweet:before{ content: "\\f079"; } w-style .fa-shopping-cart:before,[data-is="w-style"] .fa-shopping-cart:before{ content: "\\f07a"; } w-style .fa-folder:before,[data-is="w-style"] .fa-folder:before{ content: "\\f07b"; } w-style .fa-folder-open:before,[data-is="w-style"] .fa-folder-open:before{ content: "\\f07c"; } w-style .fa-arrows-v:before,[data-is="w-style"] .fa-arrows-v:before{ content: "\\f07d"; } w-style .fa-arrows-h:before,[data-is="w-style"] .fa-arrows-h:before{ content: "\\f07e"; } w-style .fa-bar-chart-o:before,[data-is="w-style"] .fa-bar-chart-o:before,w-style .fa-bar-chart:before,[data-is="w-style"] .fa-bar-chart:before{ content: "\\f080"; } w-style .fa-twitter-square:before,[data-is="w-style"] .fa-twitter-square:before{ content: "\\f081"; } w-style .fa-facebook-square:before,[data-is="w-style"] .fa-facebook-square:before{ content: "\\f082"; } w-style .fa-camera-retro:before,[data-is="w-style"] .fa-camera-retro:before{ content: "\\f083"; } w-style .fa-key:before,[data-is="w-style"] .fa-key:before{ content: "\\f084"; } w-style .fa-gears:before,[data-is="w-style"] .fa-gears:before,w-style .fa-cogs:before,[data-is="w-style"] .fa-cogs:before{ content: "\\f085"; } w-style .fa-comments:before,[data-is="w-style"] .fa-comments:before{ content: "\\f086"; } w-style .fa-thumbs-o-up:before,[data-is="w-style"] .fa-thumbs-o-up:before{ content: "\\f087"; } w-style .fa-thumbs-o-down:before,[data-is="w-style"] .fa-thumbs-o-down:before{ content: "\\f088"; } w-style .fa-star-half:before,[data-is="w-style"] .fa-star-half:before{ content: "\\f089"; } w-style .fa-heart-o:before,[data-is="w-style"] .fa-heart-o:before{ content: "\\f08a"; } w-style .fa-sign-out:before,[data-is="w-style"] .fa-sign-out:before{ content: "\\f08b"; } w-style .fa-linkedin-square:before,[data-is="w-style"] .fa-linkedin-square:before{ content: "\\f08c"; } w-style .fa-thumb-tack:before,[data-is="w-style"] .fa-thumb-tack:before{ content: "\\f08d"; } w-style .fa-external-link:before,[data-is="w-style"] .fa-external-link:before{ content: "\\f08e"; } w-style .fa-sign-in:before,[data-is="w-style"] .fa-sign-in:before{ content: "\\f090"; } w-style .fa-trophy:before,[data-is="w-style"] .fa-trophy:before{ content: "\\f091"; } w-style .fa-github-square:before,[data-is="w-style"] .fa-github-square:before{ content: "\\f092"; } w-style .fa-upload:before,[data-is="w-style"] .fa-upload:before{ content: "\\f093"; } w-style .fa-lemon-o:before,[data-is="w-style"] .fa-lemon-o:before{ content: "\\f094"; } w-style .fa-phone:before,[data-is="w-style"] .fa-phone:before{ content: "\\f095"; } w-style .fa-square-o:before,[data-is="w-style"] .fa-square-o:before{ content: "\\f096"; } w-style .fa-bookmark-o:before,[data-is="w-style"] .fa-bookmark-o:before{ content: "\\f097"; } w-style .fa-phone-square:before,[data-is="w-style"] .fa-phone-square:before{ content: "\\f098"; } w-style .fa-twitter:before,[data-is="w-style"] .fa-twitter:before{ content: "\\f099"; } w-style .fa-facebook-f:before,[data-is="w-style"] .fa-facebook-f:before,w-style .fa-facebook:before,[data-is="w-style"] .fa-facebook:before{ content: "\\f09a"; } w-style .fa-github:before,[data-is="w-style"] .fa-github:before{ content: "\\f09b"; } w-style .fa-unlock:before,[data-is="w-style"] .fa-unlock:before{ content: "\\f09c"; } w-style .fa-credit-card:before,[data-is="w-style"] .fa-credit-card:before{ content: "\\f09d"; } w-style .fa-feed:before,[data-is="w-style"] .fa-feed:before,w-style .fa-rss:before,[data-is="w-style"] .fa-rss:before{ content: "\\f09e"; } w-style .fa-hdd-o:before,[data-is="w-style"] .fa-hdd-o:before{ content: "\\f0a0"; } w-style .fa-bullhorn:before,[data-is="w-style"] .fa-bullhorn:before{ content: "\\f0a1"; } w-style .fa-bell:before,[data-is="w-style"] .fa-bell:before{ content: "\\f0f3"; } w-style .fa-certificate:before,[data-is="w-style"] .fa-certificate:before{ content: "\\f0a3"; } w-style .fa-hand-o-right:before,[data-is="w-style"] .fa-hand-o-right:before{ content: "\\f0a4"; } w-style .fa-hand-o-left:before,[data-is="w-style"] .fa-hand-o-left:before{ content: "\\f0a5"; } w-style .fa-hand-o-up:before,[data-is="w-style"] .fa-hand-o-up:before{ content: "\\f0a6"; } w-style .fa-hand-o-down:before,[data-is="w-style"] .fa-hand-o-down:before{ content: "\\f0a7"; } w-style .fa-arrow-circle-left:before,[data-is="w-style"] .fa-arrow-circle-left:before{ content: "\\f0a8"; } w-style .fa-arrow-circle-right:before,[data-is="w-style"] .fa-arrow-circle-right:before{ content: "\\f0a9"; } w-style .fa-arrow-circle-up:before,[data-is="w-style"] .fa-arrow-circle-up:before{ content: "\\f0aa"; } w-style .fa-arrow-circle-down:before,[data-is="w-style"] .fa-arrow-circle-down:before{ content: "\\f0ab"; } w-style .fa-globe:before,[data-is="w-style"] .fa-globe:before{ content: "\\f0ac"; } w-style .fa-wrench:before,[data-is="w-style"] .fa-wrench:before{ content: "\\f0ad"; } w-style .fa-tasks:before,[data-is="w-style"] .fa-tasks:before{ content: "\\f0ae"; } w-style .fa-filter:before,[data-is="w-style"] .fa-filter:before{ content: "\\f0b0"; } w-style .fa-briefcase:before,[data-is="w-style"] .fa-briefcase:before{ content: "\\f0b1"; } w-style .fa-arrows-alt:before,[data-is="w-style"] .fa-arrows-alt:before{ content: "\\f0b2"; } w-style .fa-group:before,[data-is="w-style"] .fa-group:before,w-style .fa-users:before,[data-is="w-style"] .fa-users:before{ content: "\\f0c0"; } w-style .fa-chain:before,[data-is="w-style"] .fa-chain:before,w-style .fa-link:before,[data-is="w-style"] .fa-link:before{ content: "\\f0c1"; } w-style .fa-cloud:before,[data-is="w-style"] .fa-cloud:before{ content: "\\f0c2"; } w-style .fa-flask:before,[data-is="w-style"] .fa-flask:before{ content: "\\f0c3"; } w-style .fa-cut:before,[data-is="w-style"] .fa-cut:before,w-style .fa-scissors:before,[data-is="w-style"] .fa-scissors:before{ content: "\\f0c4"; } w-style .fa-copy:before,[data-is="w-style"] .fa-copy:before,w-style .fa-files-o:before,[data-is="w-style"] .fa-files-o:before{ content: "\\f0c5"; } w-style .fa-paperclip:before,[data-is="w-style"] .fa-paperclip:before{ content: "\\f0c6"; } w-style .fa-save:before,[data-is="w-style"] .fa-save:before,w-style .fa-floppy-o:before,[data-is="w-style"] .fa-floppy-o:before{ content: "\\f0c7"; } w-style .fa-square:before,[data-is="w-style"] .fa-square:before{ content: "\\f0c8"; } w-style .fa-navicon:before,[data-is="w-style"] .fa-navicon:before,w-style .fa-reorder:before,[data-is="w-style"] .fa-reorder:before,w-style .fa-bars:before,[data-is="w-style"] .fa-bars:before{ content: "\\f0c9"; } w-style .fa-list-ul:before,[data-is="w-style"] .fa-list-ul:before{ content: "\\f0ca"; } w-style .fa-list-ol:before,[data-is="w-style"] .fa-list-ol:before{ content: "\\f0cb"; } w-style .fa-strikethrough:before,[data-is="w-style"] .fa-strikethrough:before{ content: "\\f0cc"; } w-style .fa-underline:before,[data-is="w-style"] .fa-underline:before{ content: "\\f0cd"; } w-style .fa-table:before,[data-is="w-style"] .fa-table:before{ content: "\\f0ce"; } w-style .fa-magic:before,[data-is="w-style"] .fa-magic:before{ content: "\\f0d0"; } w-style .fa-truck:before,[data-is="w-style"] .fa-truck:before{ content: "\\f0d1"; } w-style .fa-pinterest:before,[data-is="w-style"] .fa-pinterest:before{ content: "\\f0d2"; } w-style .fa-pinterest-square:before,[data-is="w-style"] .fa-pinterest-square:before{ content: "\\f0d3"; } w-style .fa-google-plus-square:before,[data-is="w-style"] .fa-google-plus-square:before{ content: "\\f0d4"; } w-style .fa-google-plus:before,[data-is="w-style"] .fa-google-plus:before{ content: "\\f0d5"; } w-style .fa-money:before,[data-is="w-style"] .fa-money:before{ content: "\\f0d6"; } w-style .fa-caret-down:before,[data-is="w-style"] .fa-caret-down:before{ content: "\\f0d7"; } w-style .fa-caret-up:before,[data-is="w-style"] .fa-caret-up:before{ content: "\\f0d8"; } w-style .fa-caret-left:before,[data-is="w-style"] .fa-caret-left:before{ content: "\\f0d9"; } w-style .fa-caret-right:before,[data-is="w-style"] .fa-caret-right:before{ content: "\\f0da"; } w-style .fa-columns:before,[data-is="w-style"] .fa-columns:before{ content: "\\f0db"; } w-style .fa-unsorted:before,[data-is="w-style"] .fa-unsorted:before,w-style .fa-sort:before,[data-is="w-style"] .fa-sort:before{ content: "\\f0dc"; } w-style .fa-sort-down:before,[data-is="w-style"] .fa-sort-down:before,w-style .fa-sort-desc:before,[data-is="w-style"] .fa-sort-desc:before{ content: "\\f0dd"; } w-style .fa-sort-up:before,[data-is="w-style"] .fa-sort-up:before,w-style .fa-sort-asc:before,[data-is="w-style"] .fa-sort-asc:before{ content: "\\f0de"; } w-style .fa-envelope:before,[data-is="w-style"] .fa-envelope:before{ content: "\\f0e0"; } w-style .fa-linkedin:before,[data-is="w-style"] .fa-linkedin:before{ content: "\\f0e1"; } w-style .fa-rotate-left:before,[data-is="w-style"] .fa-rotate-left:before,w-style .fa-undo:before,[data-is="w-style"] .fa-undo:before{ content: "\\f0e2"; } w-style .fa-legal:before,[data-is="w-style"] .fa-legal:before,w-style .fa-gavel:before,[data-is="w-style"] .fa-gavel:before{ content: "\\f0e3"; } w-style .fa-dashboard:before,[data-is="w-style"] .fa-dashboard:before,w-style .fa-tachometer:before,[data-is="w-style"] .fa-tachometer:before{ content: "\\f0e4"; } w-style .fa-comment-o:before,[data-is="w-style"] .fa-comment-o:before{ content: "\\f0e5"; } w-style .fa-comments-o:before,[data-is="w-style"] .fa-comments-o:before{ content: "\\f0e6"; } w-style .fa-flash:before,[data-is="w-style"] .fa-flash:before,w-style .fa-bolt:before,[data-is="w-style"] .fa-bolt:before{ content: "\\f0e7"; } w-style .fa-sitemap:before,[data-is="w-style"] .fa-sitemap:before{ content: "\\f0e8"; } w-style .fa-umbrella:before,[data-is="w-style"] .fa-umbrella:before{ content: "\\f0e9"; } w-style .fa-paste:before,[data-is="w-style"] .fa-paste:before,w-style .fa-clipboard:before,[data-is="w-style"] .fa-clipboard:before{ content: "\\f0ea"; } w-style .fa-lightbulb-o:before,[data-is="w-style"] .fa-lightbulb-o:before{ content: "\\f0eb"; } w-style .fa-exchange:before,[data-is="w-style"] .fa-exchange:before{ content: "\\f0ec"; } w-style .fa-cloud-download:before,[data-is="w-style"] .fa-cloud-download:before{ content: "\\f0ed"; } w-style .fa-cloud-upload:before,[data-is="w-style"] .fa-cloud-upload:before{ content: "\\f0ee"; } w-style .fa-user-md:before,[data-is="w-style"] .fa-user-md:before{ content: "\\f0f0"; } w-style .fa-stethoscope:before,[data-is="w-style"] .fa-stethoscope:before{ content: "\\f0f1"; } w-style .fa-suitcase:before,[data-is="w-style"] .fa-suitcase:before{ content: "\\f0f2"; } w-style .fa-bell-o:before,[data-is="w-style"] .fa-bell-o:before{ content: "\\f0a2"; } w-style .fa-coffee:before,[data-is="w-style"] .fa-coffee:before{ content: "\\f0f4"; } w-style .fa-cutlery:before,[data-is="w-style"] .fa-cutlery:before{ content: "\\f0f5"; } w-style .fa-file-text-o:before,[data-is="w-style"] .fa-file-text-o:before{ content: "\\f0f6"; } w-style .fa-building-o:before,[data-is="w-style"] .fa-building-o:before{ content: "\\f0f7"; } w-style .fa-hospital-o:before,[data-is="w-style"] .fa-hospital-o:before{ content: "\\f0f8"; } w-style .fa-ambulance:before,[data-is="w-style"] .fa-ambulance:before{ content: "\\f0f9"; } w-style .fa-medkit:before,[data-is="w-style"] .fa-medkit:before{ content: "\\f0fa"; } w-style .fa-fighter-jet:before,[data-is="w-style"] .fa-fighter-jet:before{ content: "\\f0fb"; } w-style .fa-beer:before,[data-is="w-style"] .fa-beer:before{ content: "\\f0fc"; } w-style .fa-h-square:before,[data-is="w-style"] .fa-h-square:before{ content: "\\f0fd"; } w-style .fa-plus-square:before,[data-is="w-style"] .fa-plus-square:before{ content: "\\f0fe"; } w-style .fa-angle-double-left:before,[data-is="w-style"] .fa-angle-double-left:before{ content: "\\f100"; } w-style .fa-angle-double-right:before,[data-is="w-style"] .fa-angle-double-right:before{ content: "\\f101"; } w-style .fa-angle-double-up:before,[data-is="w-style"] .fa-angle-double-up:before{ content: "\\f102"; } w-style .fa-angle-double-down:before,[data-is="w-style"] .fa-angle-double-down:before{ content: "\\f103"; } w-style .fa-angle-left:before,[data-is="w-style"] .fa-angle-left:before{ content: "\\f104"; } w-style .fa-angle-right:before,[data-is="w-style"] .fa-angle-right:before{ content: "\\f105"; } w-style .fa-angle-up:before,[data-is="w-style"] .fa-angle-up:before{ content: "\\f106"; } w-style .fa-angle-down:before,[data-is="w-style"] .fa-angle-down:before{ content: "\\f107"; } w-style .fa-desktop:before,[data-is="w-style"] .fa-desktop:before{ content: "\\f108"; } w-style .fa-laptop:before,[data-is="w-style"] .fa-laptop:before{ content: "\\f109"; } w-style .fa-tablet:before,[data-is="w-style"] .fa-tablet:before{ content: "\\f10a"; } w-style .fa-mobile-phone:before,[data-is="w-style"] .fa-mobile-phone:before,w-style .fa-mobile:before,[data-is="w-style"] .fa-mobile:before{ content: "\\f10b"; } w-style .fa-circle-o:before,[data-is="w-style"] .fa-circle-o:before{ content: "\\f10c"; } w-style .fa-quote-left:before,[data-is="w-style"] .fa-quote-left:before{ content: "\\f10d"; } w-style .fa-quote-right:before,[data-is="w-style"] .fa-quote-right:before{ content: "\\f10e"; } w-style .fa-spinner:before,[data-is="w-style"] .fa-spinner:before{ content: "\\f110"; } w-style .fa-circle:before,[data-is="w-style"] .fa-circle:before{ content: "\\f111"; } w-style .fa-mail-reply:before,[data-is="w-style"] .fa-mail-reply:before,w-style .fa-reply:before,[data-is="w-style"] .fa-reply:before{ content: "\\f112"; } w-style .fa-github-alt:before,[data-is="w-style"] .fa-github-alt:before{ content: "\\f113"; } w-style .fa-folder-o:before,[data-is="w-style"] .fa-folder-o:before{ content: "\\f114"; } w-style .fa-folder-open-o:before,[data-is="w-style"] .fa-folder-open-o:before{ content: "\\f115"; } w-style .fa-smile-o:before,[data-is="w-style"] .fa-smile-o:before{ content: "\\f118"; } w-style .fa-frown-o:before,[data-is="w-style"] .fa-frown-o:before{ content: "\\f119"; } w-style .fa-meh-o:before,[data-is="w-style"] .fa-meh-o:before{ content: "\\f11a"; } w-style .fa-gamepad:before,[data-is="w-style"] .fa-gamepad:before{ content: "\\f11b"; } w-style .fa-keyboard-o:before,[data-is="w-style"] .fa-keyboard-o:before{ content: "\\f11c"; } w-style .fa-flag-o:before,[data-is="w-style"] .fa-flag-o:before{ content: "\\f11d"; } w-style .fa-flag-checkered:before,[data-is="w-style"] .fa-flag-checkered:before{ content: "\\f11e"; } w-style .fa-terminal:before,[data-is="w-style"] .fa-terminal:before{ content: "\\f120"; } w-style .fa-code:before,[data-is="w-style"] .fa-code:before{ content: "\\f121"; } w-style .fa-mail-reply-all:before,[data-is="w-style"] .fa-mail-reply-all:before,w-style .fa-reply-all:before,[data-is="w-style"] .fa-reply-all:before{ content: "\\f122"; } w-style .fa-star-half-empty:before,[data-is="w-style"] .fa-star-half-empty:before,w-style .fa-star-half-full:before,[data-is="w-style"] .fa-star-half-full:before,w-style .fa-star-half-o:before,[data-is="w-style"] .fa-star-half-o:before{ content: "\\f123"; } w-style .fa-location-arrow:before,[data-is="w-style"] .fa-location-arrow:before{ content: "\\f124"; } w-style .fa-crop:before,[data-is="w-style"] .fa-crop:before{ content: "\\f125"; } w-style .fa-code-fork:before,[data-is="w-style"] .fa-code-fork:before{ content: "\\f126"; } w-style .fa-unlink:before,[data-is="w-style"] .fa-unlink:before,w-style .fa-chain-broken:before,[data-is="w-style"] .fa-chain-broken:before{ content: "\\f127"; } w-style .fa-question:before,[data-is="w-style"] .fa-question:before{ content: "\\f128"; } w-style .fa-info:before,[data-is="w-style"] .fa-info:before{ content: "\\f129"; } w-style .fa-exclamation:before,[data-is="w-style"] .fa-exclamation:before{ content: "\\f12a"; } w-style .fa-superscript:before,[data-is="w-style"] .fa-superscript:before{ content: "\\f12b"; } w-style .fa-subscript:before,[data-is="w-style"] .fa-subscript:before{ content: "\\f12c"; } w-style .fa-eraser:before,[data-is="w-style"] .fa-eraser:before{ content: "\\f12d"; } w-style .fa-puzzle-piece:before,[data-is="w-style"] .fa-puzzle-piece:before{ content: "\\f12e"; } w-style .fa-microphone:before,[data-is="w-style"] .fa-microphone:before{ content: "\\f130"; } w-style .fa-microphone-slash:before,[data-is="w-style"] .fa-microphone-slash:before{ content: "\\f131"; } w-style .fa-shield:before,[data-is="w-style"] .fa-shield:before{ content: "\\f132"; } w-style .fa-calendar-o:before,[data-is="w-style"] .fa-calendar-o:before{ content: "\\f133"; } w-style .fa-fire-extinguisher:before,[data-is="w-style"] .fa-fire-extinguisher:before{ content: "\\f134"; } w-style .fa-rocket:before,[data-is="w-style"] .fa-rocket:before{ content: "\\f135"; } w-style .fa-maxcdn:before,[data-is="w-style"] .fa-maxcdn:before{ content: "\\f136"; } w-style .fa-chevron-circle-left:before,[data-is="w-style"] .fa-chevron-circle-left:before{ content: "\\f137"; } w-style .fa-chevron-circle-right:before,[data-is="w-style"] .fa-chevron-circle-right:before{ content: "\\f138"; } w-style .fa-chevron-circle-up:before,[data-is="w-style"] .fa-chevron-circle-up:before{ content: "\\f139"; } w-style .fa-chevron-circle-down:before,[data-is="w-style"] .fa-chevron-circle-down:before{ content: "\\f13a"; } w-style .fa-html5:before,[data-is="w-style"] .fa-html5:before{ content: "\\f13b"; } w-style .fa-css3:before,[data-is="w-style"] .fa-css3:before{ content: "\\f13c"; } w-style .fa-anchor:before,[data-is="w-style"] .fa-anchor:before{ content: "\\f13d"; } w-style .fa-unlock-alt:before,[data-is="w-style"] .fa-unlock-alt:before{ content: "\\f13e"; } w-style .fa-bullseye:before,[data-is="w-style"] .fa-bullseye:before{ content: "\\f140"; } w-style .fa-ellipsis-h:before,[data-is="w-style"] .fa-ellipsis-h:before{ content: "\\f141"; } w-style .fa-ellipsis-v:before,[data-is="w-style"] .fa-ellipsis-v:before{ content: "\\f142"; } w-style .fa-rss-square:before,[data-is="w-style"] .fa-rss-square:before{ content: "\\f143"; } w-style .fa-play-circle:before,[data-is="w-style"] .fa-play-circle:before{ content: "\\f144"; } w-style .fa-ticket:before,[data-is="w-style"] .fa-ticket:before{ content: "\\f145"; } w-style .fa-minus-square:before,[data-is="w-style"] .fa-minus-square:before{ content: "\\f146"; } w-style .fa-minus-square-o:before,[data-is="w-style"] .fa-minus-square-o:before{ content: "\\f147"; } w-style .fa-level-up:before,[data-is="w-style"] .fa-level-up:before{ content: "\\f148"; } w-style .fa-level-down:before,[data-is="w-style"] .fa-level-down:before{ content: "\\f149"; } w-style .fa-check-square:before,[data-is="w-style"] .fa-check-square:before{ content: "\\f14a"; } w-style .fa-pencil-square:before,[data-is="w-style"] .fa-pencil-square:before{ content: "\\f14b"; } w-style .fa-external-link-square:before,[data-is="w-style"] .fa-external-link-square:before{ content: "\\f14c"; } w-style .fa-share-square:before,[data-is="w-style"] .fa-share-square:before{ content: "\\f14d"; } w-style .fa-compass:before,[data-is="w-style"] .fa-compass:before{ content: "\\f14e"; } w-style .fa-toggle-down:before,[data-is="w-style"] .fa-toggle-down:before,w-style .fa-caret-square-o-down:before,[data-is="w-style"] .fa-caret-square-o-down:before{ content: "\\f150"; } w-style .fa-toggle-up:before,[data-is="w-style"] .fa-toggle-up:before,w-style .fa-caret-square-o-up:before,[data-is="w-style"] .fa-caret-square-o-up:before{ content: "\\f151"; } w-style .fa-toggle-right:before,[data-is="w-style"] .fa-toggle-right:before,w-style .fa-caret-square-o-right:before,[data-is="w-style"] .fa-caret-square-o-right:before{ content: "\\f152"; } w-style .fa-euro:before,[data-is="w-style"] .fa-euro:before,w-style .fa-eur:before,[data-is="w-style"] .fa-eur:before{ content: "\\f153"; } w-style .fa-gbp:before,[data-is="w-style"] .fa-gbp:before{ content: "\\f154"; } w-style .fa-dollar:before,[data-is="w-style"] .fa-dollar:before,w-style .fa-usd:before,[data-is="w-style"] .fa-usd:before{ content: "\\f155"; } w-style .fa-rupee:before,[data-is="w-style"] .fa-rupee:before,w-style .fa-inr:before,[data-is="w-style"] .fa-inr:before{ content: "\\f156"; } w-style .fa-cny:before,[data-is="w-style"] .fa-cny:before,w-style .fa-rmb:before,[data-is="w-style"] .fa-rmb:before,w-style .fa-yen:before,[data-is="w-style"] .fa-yen:before,w-style .fa-jpy:before,[data-is="w-style"] .fa-jpy:before{ content: "\\f157"; } w-style .fa-ruble:before,[data-is="w-style"] .fa-ruble:before,w-style .fa-rouble:before,[data-is="w-style"] .fa-rouble:before,w-style .fa-rub:before,[data-is="w-style"] .fa-rub:before{ content: "\\f158"; } w-style .fa-won:before,[data-is="w-style"] .fa-won:before,w-style .fa-krw:before,[data-is="w-style"] .fa-krw:before{ content: "\\f159"; } w-style .fa-bitcoin:before,[data-is="w-style"] .fa-bitcoin:before,w-style .fa-btc:before,[data-is="w-style"] .fa-btc:before{ content: "\\f15a"; } w-style .fa-file:before,[data-is="w-style"] .fa-file:before{ content: "\\f15b"; } w-style .fa-file-text:before,[data-is="w-style"] .fa-file-text:before{ content: "\\f15c"; } w-style .fa-sort-alpha-asc:before,[data-is="w-style"] .fa-sort-alpha-asc:before{ content: "\\f15d"; } w-style .fa-sort-alpha-desc:before,[data-is="w-style"] .fa-sort-alpha-desc:before{ content: "\\f15e"; } w-style .fa-sort-amount-asc:before,[data-is="w-style"] .fa-sort-amount-asc:before{ content: "\\f160"; } w-style .fa-sort-amount-desc:before,[data-is="w-style"] .fa-sort-amount-desc:before{ content: "\\f161"; } w-style .fa-sort-numeric-asc:before,[data-is="w-style"] .fa-sort-numeric-asc:before{ content: "\\f162"; } w-style .fa-sort-numeric-desc:before,[data-is="w-style"] .fa-sort-numeric-desc:before{ content: "\\f163"; } w-style .fa-thumbs-up:before,[data-is="w-style"] .fa-thumbs-up:before{ content: "\\f164"; } w-style .fa-thumbs-down:before,[data-is="w-style"] .fa-thumbs-down:before{ content: "\\f165"; } w-style .fa-youtube-square:before,[data-is="w-style"] .fa-youtube-square:before{ content: "\\f166"; } w-style .fa-youtube:before,[data-is="w-style"] .fa-youtube:before{ content: "\\f167"; } w-style .fa-xing:before,[data-is="w-style"] .fa-xing:before{ content: "\\f168"; } w-style .fa-xing-square:before,[data-is="w-style"] .fa-xing-square:before{ content: "\\f169"; } w-style .fa-youtube-play:before,[data-is="w-style"] .fa-youtube-play:before{ content: "\\f16a"; } w-style .fa-dropbox:before,[data-is="w-style"] .fa-dropbox:before{ content: "\\f16b"; } w-style .fa-stack-overflow:before,[data-is="w-style"] .fa-stack-overflow:before{ content: "\\f16c"; } w-style .fa-instagram:before,[data-is="w-style"] .fa-instagram:before{ content: "\\f16d"; } w-style .fa-flickr:before,[data-is="w-style"] .fa-flickr:before{ content: "\\f16e"; } w-style .fa-adn:before,[data-is="w-style"] .fa-adn:before{ content: "\\f170"; } w-style .fa-bitbucket:before,[data-is="w-style"] .fa-bitbucket:before{ content: "\\f171"; } w-style .fa-bitbucket-square:before,[data-is="w-style"] .fa-bitbucket-square:before{ content: "\\f172"; } w-style .fa-tumblr:before,[data-is="w-style"] .fa-tumblr:before{ content: "\\f173"; } w-style .fa-tumblr-square:before,[data-is="w-style"] .fa-tumblr-square:before{ content: "\\f174"; } w-style .fa-long-arrow-down:before,[data-is="w-style"] .fa-long-arrow-down:before{ content: "\\f175"; } w-style .fa-long-arrow-up:before,[data-is="w-style"] .fa-long-arrow-up:before{ content: "\\f176"; } w-style .fa-long-arrow-left:before,[data-is="w-style"] .fa-long-arrow-left:before{ content: "\\f177"; } w-style .fa-long-arrow-right:before,[data-is="w-style"] .fa-long-arrow-right:before{ content: "\\f178"; } w-style .fa-apple:before,[data-is="w-style"] .fa-apple:before{ content: "\\f179"; } w-style .fa-windows:before,[data-is="w-style"] .fa-windows:before{ content: "\\f17a"; } w-style .fa-android:before,[data-is="w-style"] .fa-android:before{ content: "\\f17b"; } w-style .fa-linux:before,[data-is="w-style"] .fa-linux:before{ content: "\\f17c"; } w-style .fa-dribbble:before,[data-is="w-style"] .fa-dribbble:before{ content: "\\f17d"; } w-style .fa-skype:before,[data-is="w-style"] .fa-skype:before{ content: "\\f17e"; } w-style .fa-foursquare:before,[data-is="w-style"] .fa-foursquare:before{ content: "\\f180"; } w-style .fa-trello:before,[data-is="w-style"] .fa-trello:before{ content: "\\f181"; } w-style .fa-female:before,[data-is="w-style"] .fa-female:before{ content: "\\f182"; } w-style .fa-male:before,[data-is="w-style"] .fa-male:before{ content: "\\f183"; } w-style .fa-gittip:before,[data-is="w-style"] .fa-gittip:before,w-style .fa-gratipay:before,[data-is="w-style"] .fa-gratipay:before{ content: "\\f184"; } w-style .fa-sun-o:before,[data-is="w-style"] .fa-sun-o:before{ content: "\\f185"; } w-style .fa-moon-o:before,[data-is="w-style"] .fa-moon-o:before{ content: "\\f186"; } w-style .fa-archive:before,[data-is="w-style"] .fa-archive:before{ content: "\\f187"; } w-style .fa-bug:before,[data-is="w-style"] .fa-bug:before{ content: "\\f188"; } w-style .fa-vk:before,[data-is="w-style"] .fa-vk:before{ content: "\\f189"; } w-style .fa-weibo:before,[data-is="w-style"] .fa-weibo:before{ content: "\\f18a"; } w-style .fa-renren:before,[data-is="w-style"] .fa-renren:before{ content: "\\f18b"; } w-style .fa-pagelines:before,[data-is="w-style"] .fa-pagelines:before{ content: "\\f18c"; } w-style .fa-stack-exchange:before,[data-is="w-style"] .fa-stack-exchange:before{ content: "\\f18d"; } w-style .fa-arrow-circle-o-right:before,[data-is="w-style"] .fa-arrow-circle-o-right:before{ content: "\\f18e"; } w-style .fa-arrow-circle-o-left:before,[data-is="w-style"] .fa-arrow-circle-o-left:before{ content: "\\f190"; } w-style .fa-toggle-left:before,[data-is="w-style"] .fa-toggle-left:before,w-style .fa-caret-square-o-left:before,[data-is="w-style"] .fa-caret-square-o-left:before{ content: "\\f191"; } w-style .fa-dot-circle-o:before,[data-is="w-style"] .fa-dot-circle-o:before{ content: "\\f192"; } w-style .fa-wheelchair:before,[data-is="w-style"] .fa-wheelchair:before{ content: "\\f193"; } w-style .fa-vimeo-square:before,[data-is="w-style"] .fa-vimeo-square:before{ content: "\\f194"; } w-style .fa-turkish-lira:before,[data-is="w-style"] .fa-turkish-lira:before,w-style .fa-try:before,[data-is="w-style"] .fa-try:before{ content: "\\f195"; } w-style .fa-plus-square-o:before,[data-is="w-style"] .fa-plus-square-o:before{ content: "\\f196"; } w-style .fa-space-shuttle:before,[data-is="w-style"] .fa-space-shuttle:before{ content: "\\f197"; } w-style .fa-slack:before,[data-is="w-style"] .fa-slack:before{ content: "\\f198"; } w-style .fa-envelope-square:before,[data-is="w-style"] .fa-envelope-square:before{ content: "\\f199"; } w-style .fa-wordpress:before,[data-is="w-style"] .fa-wordpress:before{ content: "\\f19a"; } w-style .fa-openid:before,[data-is="w-style"] .fa-openid:before{ content: "\\f19b"; } w-style .fa-institution:before,[data-is="w-style"] .fa-institution:before,w-style .fa-bank:before,[data-is="w-style"] .fa-bank:before,w-style .fa-university:before,[data-is="w-style"] .fa-university:before{ content: "\\f19c"; } w-style .fa-mortar-board:before,[data-is="w-style"] .fa-mortar-board:before,w-style .fa-graduation-cap:before,[data-is="w-style"] .fa-graduation-cap:before{ content: "\\f19d"; } w-style .fa-yahoo:before,[data-is="w-style"] .fa-yahoo:before{ content: "\\f19e"; } w-style .fa-google:before,[data-is="w-style"] .fa-google:before{ content: "\\f1a0"; } w-style .fa-reddit:before,[data-is="w-style"] .fa-reddit:before{ content: "\\f1a1"; } w-style .fa-reddit-square:before,[data-is="w-style"] .fa-reddit-square:before{ content: "\\f1a2"; } w-style .fa-stumbleupon-circle:before,[data-is="w-style"] .fa-stumbleupon-circle:before{ content: "\\f1a3"; } w-style .fa-stumbleupon:before,[data-is="w-style"] .fa-stumbleupon:before{ content: "\\f1a4"; } w-style .fa-delicious:before,[data-is="w-style"] .fa-delicious:before{ content: "\\f1a5"; } w-style .fa-digg:before,[data-is="w-style"] .fa-digg:before{ content: "\\f1a6"; } w-style .fa-pied-piper-pp:before,[data-is="w-style"] .fa-pied-piper-pp:before{ content: "\\f1a7"; } w-style .fa-pied-piper-alt:before,[data-is="w-style"] .fa-pied-piper-alt:before{ content: "\\f1a8"; } w-style .fa-drupal:before,[data-is="w-style"] .fa-drupal:before{ content: "\\f1a9"; } w-style .fa-joomla:before,[data-is="w-style"] .fa-joomla:before{ content: "\\f1aa"; } w-style .fa-language:before,[data-is="w-style"] .fa-language:before{ content: "\\f1ab"; } w-style .fa-fax:before,[data-is="w-style"] .fa-fax:before{ content: "\\f1ac"; } w-style .fa-building:before,[data-is="w-style"] .fa-building:before{ content: "\\f1ad"; } w-style .fa-child:before,[data-is="w-style"] .fa-child:before{ content: "\\f1ae"; } w-style .fa-paw:before,[data-is="w-style"] .fa-paw:before{ content: "\\f1b0"; } w-style .fa-spoon:before,[data-is="w-style"] .fa-spoon:before{ content: "\\f1b1"; } w-style .fa-cube:before,[data-is="w-style"] .fa-cube:before{ content: "\\f1b2"; } w-style .fa-cubes:before,[data-is="w-style"] .fa-cubes:before{ content: "\\f1b3"; } w-style .fa-behance:before,[data-is="w-style"] .fa-behance:before{ content: "\\f1b4"; } w-style .fa-behance-square:before,[data-is="w-style"] .fa-behance-square:before{ content: "\\f1b5"; } w-style .fa-steam:before,[data-is="w-style"] .fa-steam:before{ content: "\\f1b6"; } w-style .fa-steam-square:before,[data-is="w-style"] .fa-steam-square:before{ content: "\\f1b7"; } w-style .fa-recycle:before,[data-is="w-style"] .fa-recycle:before{ content: "\\f1b8"; } w-style .fa-automobile:before,[data-is="w-style"] .fa-automobile:before,w-style .fa-car:before,[data-is="w-style"] .fa-car:before{ content: "\\f1b9"; } w-style .fa-cab:before,[data-is="w-style"] .fa-cab:before,w-style .fa-taxi:before,[data-is="w-style"] .fa-taxi:before{ content: "\\f1ba"; } w-style .fa-tree:before,[data-is="w-style"] .fa-tree:before{ content: "\\f1bb"; } w-style .fa-spotify:before,[data-is="w-style"] .fa-spotify:before{ content: "\\f1bc"; } w-style .fa-deviantart:before,[data-is="w-style"] .fa-deviantart:before{ content: "\\f1bd"; } w-style .fa-soundcloud:before,[data-is="w-style"] .fa-soundcloud:before{ content: "\\f1be"; } w-style .fa-database:before,[data-is="w-style"] .fa-database:before{ content: "\\f1c0"; } w-style .fa-file-pdf-o:before,[data-is="w-style"] .fa-file-pdf-o:before{ content: "\\f1c1"; } w-style .fa-file-word-o:before,[data-is="w-style"] .fa-file-word-o:before{ content: "\\f1c2"; } w-style .fa-file-excel-o:before,[data-is="w-style"] .fa-file-excel-o:before{ content: "\\f1c3"; } w-style .fa-file-powerpoint-o:before,[data-is="w-style"] .fa-file-powerpoint-o:before{ content: "\\f1c4"; } w-style .fa-file-photo-o:before,[data-is="w-style"] .fa-file-photo-o:before,w-style .fa-file-picture-o:before,[data-is="w-style"] .fa-file-picture-o:before,w-style .fa-file-image-o:before,[data-is="w-style"] .fa-file-image-o:before{ content: "\\f1c5"; } w-style .fa-file-zip-o:before,[data-is="w-style"] .fa-file-zip-o:before,w-style .fa-file-archive-o:before,[data-is="w-style"] .fa-file-archive-o:before{ content: "\\f1c6"; } w-style .fa-file-sound-o:before,[data-is="w-style"] .fa-file-sound-o:before,w-style .fa-file-audio-o:before,[data-is="w-style"] .fa-file-audio-o:before{ content: "\\f1c7"; } w-style .fa-file-movie-o:before,[data-is="w-style"] .fa-file-movie-o:before,w-style .fa-file-video-o:before,[data-is="w-style"] .fa-file-video-o:before{ content: "\\f1c8"; } w-style .fa-file-code-o:before,[data-is="w-style"] .fa-file-code-o:before{ content: "\\f1c9"; } w-style .fa-vine:before,[data-is="w-style"] .fa-vine:before{ content: "\\f1ca"; } w-style .fa-codepen:before,[data-is="w-style"] .fa-codepen:before{ content: "\\f1cb"; } w-style .fa-jsfiddle:before,[data-is="w-style"] .fa-jsfiddle:before{ content: "\\f1cc"; } w-style .fa-life-bouy:before,[data-is="w-style"] .fa-life-bouy:before,w-style .fa-life-buoy:before,[data-is="w-style"] .fa-life-buoy:before,w-style .fa-life-saver:before,[data-is="w-style"] .fa-life-saver:before,w-style .fa-support:before,[data-is="w-style"] .fa-support:before,w-style .fa-life-ring:before,[data-is="w-style"] .fa-life-ring:before{ content: "\\f1cd"; } w-style .fa-circle-o-notch:before,[data-is="w-style"] .fa-circle-o-notch:before{ content: "\\f1ce"; } w-style .fa-ra:before,[data-is="w-style"] .fa-ra:before,w-style .fa-resistance:before,[data-is="w-style"] .fa-resistance:before,w-style .fa-rebel:before,[data-is="w-style"] .fa-rebel:before{ content: "\\f1d0"; } w-style .fa-ge:before,[data-is="w-style"] .fa-ge:before,w-style .fa-empire:before,[data-is="w-style"] .fa-empire:before{ content: "\\f1d1"; } w-style .fa-git-square:before,[data-is="w-style"] .fa-git-square:before{ content: "\\f1d2"; } w-style .fa-git:before,[data-is="w-style"] .fa-git:before{ content: "\\f1d3"; } w-style .fa-y-combinator-square:before,[data-is="w-style"] .fa-y-combinator-square:before,w-style .fa-yc-square:before,[data-is="w-style"] .fa-yc-square:before,w-style .fa-hacker-news:before,[data-is="w-style"] .fa-hacker-news:before{ content: "\\f1d4"; } w-style .fa-tencent-weibo:before,[data-is="w-style"] .fa-tencent-weibo:before{ content: "\\f1d5"; } w-style .fa-qq:before,[data-is="w-style"] .fa-qq:before{ content: "\\f1d6"; } w-style .fa-wechat:before,[data-is="w-style"] .fa-wechat:before,w-style .fa-weixin:before,[data-is="w-style"] .fa-weixin:before{ content: "\\f1d7"; } w-style .fa-send:before,[data-is="w-style"] .fa-send:before,w-style .fa-paper-plane:before,[data-is="w-style"] .fa-paper-plane:before{ content: "\\f1d8"; } w-style .fa-send-o:before,[data-is="w-style"] .fa-send-o:before,w-style .fa-paper-plane-o:before,[data-is="w-style"] .fa-paper-plane-o:before{ content: "\\f1d9"; } w-style .fa-history:before,[data-is="w-style"] .fa-history:before{ content: "\\f1da"; } w-style .fa-circle-thin:before,[data-is="w-style"] .fa-circle-thin:before{ content: "\\f1db"; } w-style .fa-header:before,[data-is="w-style"] .fa-header:before{ content: "\\f1dc"; } w-style .fa-paragraph:before,[data-is="w-style"] .fa-paragraph:before{ content: "\\f1dd"; } w-style .fa-sliders:before,[data-is="w-style"] .fa-sliders:before{ content: "\\f1de"; } w-style .fa-share-alt:before,[data-is="w-style"] .fa-share-alt:before{ content: "\\f1e0"; } w-style .fa-share-alt-square:before,[data-is="w-style"] .fa-share-alt-square:before{ content: "\\f1e1"; } w-style .fa-bomb:before,[data-is="w-style"] .fa-bomb:before{ content: "\\f1e2"; } w-style .fa-soccer-ball-o:before,[data-is="w-style"] .fa-soccer-ball-o:before,w-style .fa-futbol-o:before,[data-is="w-style"] .fa-futbol-o:before{ content: "\\f1e3"; } w-style .fa-tty:before,[data-is="w-style"] .fa-tty:before{ content: "\\f1e4"; } w-style .fa-binoculars:before,[data-is="w-style"] .fa-binoculars:before{ content: "\\f1e5"; } w-style .fa-plug:before,[data-is="w-style"] .fa-plug:before{ content: "\\f1e6"; } w-style .fa-slideshare:before,[data-is="w-style"] .fa-slideshare:before{ content: "\\f1e7"; } w-style .fa-twitch:before,[data-is="w-style"] .fa-twitch:before{ content: "\\f1e8"; } w-style .fa-yelp:before,[data-is="w-style"] .fa-yelp:before{ content: "\\f1e9"; } w-style .fa-newspaper-o:before,[data-is="w-style"] .fa-newspaper-o:before{ content: "\\f1ea"; } w-style .fa-wifi:before,[data-is="w-style"] .fa-wifi:before{ content: "\\f1eb"; } w-style .fa-calculator:before,[data-is="w-style"] .fa-calculator:before{ content: "\\f1ec"; } w-style .fa-paypal:before,[data-is="w-style"] .fa-paypal:before{ content: "\\f1ed"; } w-style .fa-google-wallet:before,[data-is="w-style"] .fa-google-wallet:before{ content: "\\f1ee"; } w-style .fa-cc-visa:before,[data-is="w-style"] .fa-cc-visa:before{ content: "\\f1f0"; } w-style .fa-cc-mastercard:before,[data-is="w-style"] .fa-cc-mastercard:before{ content: "\\f1f1"; } w-style .fa-cc-discover:before,[data-is="w-style"] .fa-cc-discover:before{ content: "\\f1f2"; } w-style .fa-cc-amex:before,[data-is="w-style"] .fa-cc-amex:before{ content: "\\f1f3"; } w-style .fa-cc-paypal:before,[data-is="w-style"] .fa-cc-paypal:before{ content: "\\f1f4"; } w-style .fa-cc-stripe:before,[data-is="w-style"] .fa-cc-stripe:before{ content: "\\f1f5"; } w-style .fa-bell-slash:before,[data-is="w-style"] .fa-bell-slash:before{ content: "\\f1f6"; } w-style .fa-bell-slash-o:before,[data-is="w-style"] .fa-bell-slash-o:before{ content: "\\f1f7"; } w-style .fa-trash:before,[data-is="w-style"] .fa-trash:before{ content: "\\f1f8"; } w-style .fa-copyright:before,[data-is="w-style"] .fa-copyright:before{ content: "\\f1f9"; } w-style .fa-at:before,[data-is="w-style"] .fa-at:before{ content: "\\f1fa"; } w-style .fa-eyedropper:before,[data-is="w-style"] .fa-eyedropper:before{ content: "\\f1fb"; } w-style .fa-paint-brush:before,[data-is="w-style"] .fa-paint-brush:before{ content: "\\f1fc"; } w-style .fa-birthday-cake:before,[data-is="w-style"] .fa-birthday-cake:before{ content: "\\f1fd"; } w-style .fa-area-chart:before,[data-is="w-style"] .fa-area-chart:before{ content: "\\f1fe"; } w-style .fa-pie-chart:before,[data-is="w-style"] .fa-pie-chart:before{ content: "\\f200"; } w-style .fa-line-chart:before,[data-is="w-style"] .fa-line-chart:before{ content: "\\f201"; } w-style .fa-lastfm:before,[data-is="w-style"] .fa-lastfm:before{ content: "\\f202"; } w-style .fa-lastfm-square:before,[data-is="w-style"] .fa-lastfm-square:before{ content: "\\f203"; } w-style .fa-toggle-off:before,[data-is="w-style"] .fa-toggle-off:before{ content: "\\f204"; } w-style .fa-toggle-on:before,[data-is="w-style"] .fa-toggle-on:before{ content: "\\f205"; } w-style .fa-bicycle:before,[data-is="w-style"] .fa-bicycle:before{ content: "\\f206"; } w-style .fa-bus:before,[data-is="w-style"] .fa-bus:before{ content: "\\f207"; } w-style .fa-ioxhost:before,[data-is="w-style"] .fa-ioxhost:before{ content: "\\f208"; } w-style .fa-angellist:before,[data-is="w-style"] .fa-angellist:before{ content: "\\f209"; } w-style .fa-cc:before,[data-is="w-style"] .fa-cc:before{ content: "\\f20a"; } w-style .fa-shekel:before,[data-is="w-style"] .fa-shekel:before,w-style .fa-sheqel:before,[data-is="w-style"] .fa-sheqel:before,w-style .fa-ils:before,[data-is="w-style"] .fa-ils:before{ content: "\\f20b"; } w-style .fa-meanpath:before,[data-is="w-style"] .fa-meanpath:before{ content: "\\f20c"; } w-style .fa-buysellads:before,[data-is="w-style"] .fa-buysellads:before{ content: "\\f20d"; } w-style .fa-connectdevelop:before,[data-is="w-style"] .fa-connectdevelop:before{ content: "\\f20e"; } w-style .fa-dashcube:before,[data-is="w-style"] .fa-dashcube:before{ content: "\\f210"; } w-style .fa-forumbee:before,[data-is="w-style"] .fa-forumbee:before{ content: "\\f211"; } w-style .fa-leanpub:before,[data-is="w-style"] .fa-leanpub:before{ content: "\\f212"; } w-style .fa-sellsy:before,[data-is="w-style"] .fa-sellsy:before{ content: "\\f213"; } w-style .fa-shirtsinbulk:before,[data-is="w-style"] .fa-shirtsinbulk:before{ content: "\\f214"; } w-style .fa-simplybuilt:before,[data-is="w-style"] .fa-simplybuilt:before{ content: "\\f215"; } w-style .fa-skyatlas:before,[data-is="w-style"] .fa-skyatlas:before{ content: "\\f216"; } w-style .fa-cart-plus:before,[data-is="w-style"] .fa-cart-plus:before{ content: "\\f217"; } w-style .fa-cart-arrow-down:before,[data-is="w-style"] .fa-cart-arrow-down:before{ content: "\\f218"; } w-style .fa-diamond:before,[data-is="w-style"] .fa-diamond:before{ content: "\\f219"; } w-style .fa-ship:before,[data-is="w-style"] .fa-ship:before{ content: "\\f21a"; } w-style .fa-user-secret:before,[data-is="w-style"] .fa-user-secret:before{ content: "\\f21b"; } w-style .fa-motorcycle:before,[data-is="w-style"] .fa-motorcycle:before{ content: "\\f21c"; } w-style .fa-street-view:before,[data-is="w-style"] .fa-street-view:before{ content: "\\f21d"; } w-style .fa-heartbeat:before,[data-is="w-style"] .fa-heartbeat:before{ content: "\\f21e"; } w-style .fa-venus:before,[data-is="w-style"] .fa-venus:before{ content: "\\f221"; } w-style .fa-mars:before,[data-is="w-style"] .fa-mars:before{ content: "\\f222"; } w-style .fa-mercury:before,[data-is="w-style"] .fa-mercury:before{ content: "\\f223"; } w-style .fa-intersex:before,[data-is="w-style"] .fa-intersex:before,w-style .fa-transgender:before,[data-is="w-style"] .fa-transgender:before{ content: "\\f224"; } w-style .fa-transgender-alt:before,[data-is="w-style"] .fa-transgender-alt:before{ content: "\\f225"; } w-style .fa-venus-double:before,[data-is="w-style"] .fa-venus-double:before{ content: "\\f226"; } w-style .fa-mars-double:before,[data-is="w-style"] .fa-mars-double:before{ content: "\\f227"; } w-style .fa-venus-mars:before,[data-is="w-style"] .fa-venus-mars:before{ content: "\\f228"; } w-style .fa-mars-stroke:before,[data-is="w-style"] .fa-mars-stroke:before{ content: "\\f229"; } w-style .fa-mars-stroke-v:before,[data-is="w-style"] .fa-mars-stroke-v:before{ content: "\\f22a"; } w-style .fa-mars-stroke-h:before,[data-is="w-style"] .fa-mars-stroke-h:before{ content: "\\f22b"; } w-style .fa-neuter:before,[data-is="w-style"] .fa-neuter:before{ content: "\\f22c"; } w-style .fa-genderless:before,[data-is="w-style"] .fa-genderless:before{ content: "\\f22d"; } w-style .fa-facebook-official:before,[data-is="w-style"] .fa-facebook-official:before{ content: "\\f230"; } w-style .fa-pinterest-p:before,[data-is="w-style"] .fa-pinterest-p:before{ content: "\\f231"; } w-style .fa-whatsapp:before,[data-is="w-style"] .fa-whatsapp:before{ content: "\\f232"; } w-style .fa-server:before,[data-is="w-style"] .fa-server:before{ content: "\\f233"; } w-style .fa-user-plus:before,[data-is="w-style"] .fa-user-plus:before{ content: "\\f234"; } w-style .fa-user-times:before,[data-is="w-style"] .fa-user-times:before{ content: "\\f235"; } w-style .fa-hotel:before,[data-is="w-style"] .fa-hotel:before,w-style .fa-bed:before,[data-is="w-style"] .fa-bed:before{ content: "\\f236"; } w-style .fa-viacoin:before,[data-is="w-style"] .fa-viacoin:before{ content: "\\f237"; } w-style .fa-train:before,[data-is="w-style"] .fa-train:before{ content: "\\f238"; } w-style .fa-subway:before,[data-is="w-style"] .fa-subway:before{ content: "\\f239"; } w-style .fa-medium:before,[data-is="w-style"] .fa-medium:before{ content: "\\f23a"; } w-style .fa-yc:before,[data-is="w-style"] .fa-yc:before,w-style .fa-y-combinator:before,[data-is="w-style"] .fa-y-combinator:before{ content: "\\f23b"; } w-style .fa-optin-monster:before,[data-is="w-style"] .fa-optin-monster:before{ content: "\\f23c"; } w-style .fa-opencart:before,[data-is="w-style"] .fa-opencart:before{ content: "\\f23d"; } w-style .fa-expeditedssl:before,[data-is="w-style"] .fa-expeditedssl:before{ content: "\\f23e"; } w-style .fa-battery-4:before,[data-is="w-style"] .fa-battery-4:before,w-style .fa-battery:before,[data-is="w-style"] .fa-battery:before,w-style .fa-battery-full:before,[data-is="w-style"] .fa-battery-full:before{ content: "\\f240"; } w-style .fa-battery-3:before,[data-is="w-style"] .fa-battery-3:before,w-style .fa-battery-three-quarters:before,[data-is="w-style"] .fa-battery-three-quarters:before{ content: "\\f241"; } w-style .fa-battery-2:before,[data-is="w-style"] .fa-battery-2:before,w-style .fa-battery-half:before,[data-is="w-style"] .fa-battery-half:before{ content: "\\f242"; } w-style .fa-battery-1:before,[data-is="w-style"] .fa-battery-1:before,w-style .fa-battery-quarter:before,[data-is="w-style"] .fa-battery-quarter:before{ content: "\\f243"; } w-style .fa-battery-0:before,[data-is="w-style"] .fa-battery-0:before,w-style .fa-battery-empty:before,[data-is="w-style"] .fa-battery-empty:before{ content: "\\f244"; } w-style .fa-mouse-pointer:before,[data-is="w-style"] .fa-mouse-pointer:before{ content: "\\f245"; } w-style .fa-i-cursor:before,[data-is="w-style"] .fa-i-cursor:before{ content: "\\f246"; } w-style .fa-object-group:before,[data-is="w-style"] .fa-object-group:before{ content: "\\f247"; } w-style .fa-object-ungroup:before,[data-is="w-style"] .fa-object-ungroup:before{ content: "\\f248"; } w-style .fa-sticky-note:before,[data-is="w-style"] .fa-sticky-note:before{ content: "\\f249"; } w-style .fa-sticky-note-o:before,[data-is="w-style"] .fa-sticky-note-o:before{ content: "\\f24a"; } w-style .fa-cc-jcb:before,[data-is="w-style"] .fa-cc-jcb:before{ content: "\\f24b"; } w-style .fa-cc-diners-club:before,[data-is="w-style"] .fa-cc-diners-club:before{ content: "\\f24c"; } w-style .fa-clone:before,[data-is="w-style"] .fa-clone:before{ content: "\\f24d"; } w-style .fa-balance-scale:before,[data-is="w-style"] .fa-balance-scale:before{ content: "\\f24e"; } w-style .fa-hourglass-o:before,[data-is="w-style"] .fa-hourglass-o:before{ content: "\\f250"; } w-style .fa-hourglass-1:before,[data-is="w-style"] .fa-hourglass-1:before,w-style .fa-hourglass-start:before,[data-is="w-style"] .fa-hourglass-start:before{ content: "\\f251"; } w-style .fa-hourglass-2:before,[data-is="w-style"] .fa-hourglass-2:before,w-style .fa-hourglass-half:before,[data-is="w-style"] .fa-hourglass-half:before{ content: "\\f252"; } w-style .fa-hourglass-3:before,[data-is="w-style"] .fa-hourglass-3:before,w-style .fa-hourglass-end:before,[data-is="w-style"] .fa-hourglass-end:before{ content: "\\f253"; } w-style .fa-hourglass:before,[data-is="w-style"] .fa-hourglass:before{ content: "\\f254"; } w-style .fa-hand-grab-o:before,[data-is="w-style"] .fa-hand-grab-o:before,w-style .fa-hand-rock-o:before,[data-is="w-style"] .fa-hand-rock-o:before{ content: "\\f255"; } w-style .fa-hand-stop-o:before,[data-is="w-style"] .fa-hand-stop-o:before,w-style .fa-hand-paper-o:before,[data-is="w-style"] .fa-hand-paper-o:before{ content: "\\f256"; } w-style .fa-hand-scissors-o:before,[data-is="w-style"] .fa-hand-scissors-o:before{ content: "\\f257"; } w-style .fa-hand-lizard-o:before,[data-is="w-style"] .fa-hand-lizard-o:before{ content: "\\f258"; } w-style .fa-hand-spock-o:before,[data-is="w-style"] .fa-hand-spock-o:before{ content: "\\f259"; } w-style .fa-hand-pointer-o:before,[data-is="w-style"] .fa-hand-pointer-o:before{ content: "\\f25a"; } w-style .fa-hand-peace-o:before,[data-is="w-style"] .fa-hand-peace-o:before{ content: "\\f25b"; } w-style .fa-trademark:before,[data-is="w-style"] .fa-trademark:before{ content: "\\f25c"; } w-style .fa-registered:before,[data-is="w-style"] .fa-registered:before{ content: "\\f25d"; } w-style .fa-creative-commons:before,[data-is="w-style"] .fa-creative-commons:before{ content: "\\f25e"; } w-style .fa-gg:before,[data-is="w-style"] .fa-gg:before{ content: "\\f260"; } w-style .fa-gg-circle:before,[data-is="w-style"] .fa-gg-circle:before{ content: "\\f261"; } w-style .fa-tripadvisor:before,[data-is="w-style"] .fa-tripadvisor:before{ content: "\\f262"; } w-style .fa-odnoklassniki:before,[data-is="w-style"] .fa-odnoklassniki:before{ content: "\\f263"; } w-style .fa-odnoklassniki-square:before,[data-is="w-style"] .fa-odnoklassniki-square:before{ content: "\\f264"; } w-style .fa-get-pocket:before,[data-is="w-style"] .fa-get-pocket:before{ content: "\\f265"; } w-style .fa-wikipedia-w:before,[data-is="w-style"] .fa-wikipedia-w:before{ content: "\\f266"; } w-style .fa-safari:before,[data-is="w-style"] .fa-safari:before{ content: "\\f267"; } w-style .fa-chrome:before,[data-is="w-style"] .fa-chrome:before{ content: "\\f268"; } w-style .fa-firefox:before,[data-is="w-style"] .fa-firefox:before{ content: "\\f269"; } w-style .fa-opera:before,[data-is="w-style"] .fa-opera:before{ content: "\\f26a"; } w-style .fa-internet-explorer:before,[data-is="w-style"] .fa-internet-explorer:before{ content: "\\f26b"; } w-style .fa-tv:before,[data-is="w-style"] .fa-tv:before,w-style .fa-television:before,[data-is="w-style"] .fa-television:before{ content: "\\f26c"; } w-style .fa-contao:before,[data-is="w-style"] .fa-contao:before{ content: "\\f26d"; } w-style .fa-500px:before,[data-is="w-style"] .fa-500px:before{ content: "\\f26e"; } w-style .fa-amazon:before,[data-is="w-style"] .fa-amazon:before{ content: "\\f270"; } w-style .fa-calendar-plus-o:before,[data-is="w-style"] .fa-calendar-plus-o:before{ content: "\\f271"; } w-style .fa-calendar-minus-o:before,[data-is="w-style"] .fa-calendar-minus-o:before{ content: "\\f272"; } w-style .fa-calendar-times-o:before,[data-is="w-style"] .fa-calendar-times-o:before{ content: "\\f273"; } w-style .fa-calendar-check-o:before,[data-is="w-style"] .fa-calendar-check-o:before{ content: "\\f274"; } w-style .fa-industry:before,[data-is="w-style"] .fa-industry:before{ content: "\\f275"; } w-style .fa-map-pin:before,[data-is="w-style"] .fa-map-pin:before{ content: "\\f276"; } w-style .fa-map-signs:before,[data-is="w-style"] .fa-map-signs:before{ content: "\\f277"; } w-style .fa-map-o:before,[data-is="w-style"] .fa-map-o:before{ content: "\\f278"; } w-style .fa-map:before,[data-is="w-style"] .fa-map:before{ content: "\\f279"; } w-style .fa-commenting:before,[data-is="w-style"] .fa-commenting:before{ content: "\\f27a"; } w-style .fa-commenting-o:before,[data-is="w-style"] .fa-commenting-o:before{ content: "\\f27b"; } w-style .fa-houzz:before,[data-is="w-style"] .fa-houzz:before{ content: "\\f27c"; } w-style .fa-vimeo:before,[data-is="w-style"] .fa-vimeo:before{ content: "\\f27d"; } w-style .fa-black-tie:before,[data-is="w-style"] .fa-black-tie:before{ content: "\\f27e"; } w-style .fa-fonticons:before,[data-is="w-style"] .fa-fonticons:before{ content: "\\f280"; } w-style .fa-reddit-alien:before,[data-is="w-style"] .fa-reddit-alien:before{ content: "\\f281"; } w-style .fa-edge:before,[data-is="w-style"] .fa-edge:before{ content: "\\f282"; } w-style .fa-credit-card-alt:before,[data-is="w-style"] .fa-credit-card-alt:before{ content: "\\f283"; } w-style .fa-codiepie:before,[data-is="w-style"] .fa-codiepie:before{ content: "\\f284"; } w-style .fa-modx:before,[data-is="w-style"] .fa-modx:before{ content: "\\f285"; } w-style .fa-fort-awesome:before,[data-is="w-style"] .fa-fort-awesome:before{ content: "\\f286"; } w-style .fa-usb:before,[data-is="w-style"] .fa-usb:before{ content: "\\f287"; } w-style .fa-product-hunt:before,[data-is="w-style"] .fa-product-hunt:before{ content: "\\f288"; } w-style .fa-mixcloud:before,[data-is="w-style"] .fa-mixcloud:before{ content: "\\f289"; } w-style .fa-scribd:before,[data-is="w-style"] .fa-scribd:before{ content: "\\f28a"; } w-style .fa-pause-circle:before,[data-is="w-style"] .fa-pause-circle:before{ content: "\\f28b"; } w-style .fa-pause-circle-o:before,[data-is="w-style"] .fa-pause-circle-o:before{ content: "\\f28c"; } w-style .fa-stop-circle:before,[data-is="w-style"] .fa-stop-circle:before{ content: "\\f28d"; } w-style .fa-stop-circle-o:before,[data-is="w-style"] .fa-stop-circle-o:before{ content: "\\f28e"; } w-style .fa-shopping-bag:before,[data-is="w-style"] .fa-shopping-bag:before{ content: "\\f290"; } w-style .fa-shopping-basket:before,[data-is="w-style"] .fa-shopping-basket:before{ content: "\\f291"; } w-style .fa-hashtag:before,[data-is="w-style"] .fa-hashtag:before{ content: "\\f292"; } w-style .fa-bluetooth:before,[data-is="w-style"] .fa-bluetooth:before{ content: "\\f293"; } w-style .fa-bluetooth-b:before,[data-is="w-style"] .fa-bluetooth-b:before{ content: "\\f294"; } w-style .fa-percent:before,[data-is="w-style"] .fa-percent:before{ content: "\\f295"; } w-style .fa-gitlab:before,[data-is="w-style"] .fa-gitlab:before{ content: "\\f296"; } w-style .fa-wpbeginner:before,[data-is="w-style"] .fa-wpbeginner:before{ content: "\\f297"; } w-style .fa-wpforms:before,[data-is="w-style"] .fa-wpforms:before{ content: "\\f298"; } w-style .fa-envira:before,[data-is="w-style"] .fa-envira:before{ content: "\\f299"; } w-style .fa-universal-access:before,[data-is="w-style"] .fa-universal-access:before{ content: "\\f29a"; } w-style .fa-wheelchair-alt:before,[data-is="w-style"] .fa-wheelchair-alt:before{ content: "\\f29b"; } w-style .fa-question-circle-o:before,[data-is="w-style"] .fa-question-circle-o:before{ content: "\\f29c"; } w-style .fa-blind:before,[data-is="w-style"] .fa-blind:before{ content: "\\f29d"; } w-style .fa-audio-description:before,[data-is="w-style"] .fa-audio-description:before{ content: "\\f29e"; } w-style .fa-volume-control-phone:before,[data-is="w-style"] .fa-volume-control-phone:before{ content: "\\f2a0"; } w-style .fa-braille:before,[data-is="w-style"] .fa-braille:before{ content: "\\f2a1"; } w-style .fa-assistive-listening-systems:before,[data-is="w-style"] .fa-assistive-listening-systems:before{ content: "\\f2a2"; } w-style .fa-asl-interpreting:before,[data-is="w-style"] .fa-asl-interpreting:before,w-style .fa-american-sign-language-interpreting:before,[data-is="w-style"] .fa-american-sign-language-interpreting:before{ content: "\\f2a3"; } w-style .fa-deafness:before,[data-is="w-style"] .fa-deafness:before,w-style .fa-hard-of-hearing:before,[data-is="w-style"] .fa-hard-of-hearing:before,w-style .fa-deaf:before,[data-is="w-style"] .fa-deaf:before{ content: "\\f2a4"; } w-style .fa-glide:before,[data-is="w-style"] .fa-glide:before{ content: "\\f2a5"; } w-style .fa-glide-g:before,[data-is="w-style"] .fa-glide-g:before{ content: "\\f2a6"; } w-style .fa-signing:before,[data-is="w-style"] .fa-signing:before,w-style .fa-sign-language:before,[data-is="w-style"] .fa-sign-language:before{ content: "\\f2a7"; } w-style .fa-low-vision:before,[data-is="w-style"] .fa-low-vision:before{ content: "\\f2a8"; } w-style .fa-viadeo:before,[data-is="w-style"] .fa-viadeo:before{ content: "\\f2a9"; } w-style .fa-viadeo-square:before,[data-is="w-style"] .fa-viadeo-square:before{ content: "\\f2aa"; } w-style .fa-snapchat:before,[data-is="w-style"] .fa-snapchat:before{ content: "\\f2ab"; } w-style .fa-snapchat-ghost:before,[data-is="w-style"] .fa-snapchat-ghost:before{ content: "\\f2ac"; } w-style .fa-snapchat-square:before,[data-is="w-style"] .fa-snapchat-square:before{ content: "\\f2ad"; } w-style .fa-pied-piper:before,[data-is="w-style"] .fa-pied-piper:before{ content: "\\f2ae"; } w-style .fa-first-order:before,[data-is="w-style"] .fa-first-order:before{ content: "\\f2b0"; } w-style .fa-yoast:before,[data-is="w-style"] .fa-yoast:before{ content: "\\f2b1"; } w-style .fa-themeisle:before,[data-is="w-style"] .fa-themeisle:before{ content: "\\f2b2"; } w-style .fa-google-plus-circle:before,[data-is="w-style"] .fa-google-plus-circle:before,w-style .fa-google-plus-official:before,[data-is="w-style"] .fa-google-plus-official:before{ content: "\\f2b3"; } w-style .fa-fa:before,[data-is="w-style"] .fa-fa:before,w-style .fa-font-awesome:before,[data-is="w-style"] .fa-font-awesome:before{ content: "\\f2b4"; } w-style .fa-handshake-o:before,[data-is="w-style"] .fa-handshake-o:before{ content: "\\f2b5"; } w-style .fa-envelope-open:before,[data-is="w-style"] .fa-envelope-open:before{ content: "\\f2b6"; } w-style .fa-envelope-open-o:before,[data-is="w-style"] .fa-envelope-open-o:before{ content: "\\f2b7"; } w-style .fa-linode:before,[data-is="w-style"] .fa-linode:before{ content: "\\f2b8"; } w-style .fa-address-book:before,[data-is="w-style"] .fa-address-book:before{ content: "\\f2b9"; } w-style .fa-address-book-o:before,[data-is="w-style"] .fa-address-book-o:before{ content: "\\f2ba"; } w-style .fa-vcard:before,[data-is="w-style"] .fa-vcard:before,w-style .fa-address-card:before,[data-is="w-style"] .fa-address-card:before{ content: "\\f2bb"; } w-style .fa-vcard-o:before,[data-is="w-style"] .fa-vcard-o:before,w-style .fa-address-card-o:before,[data-is="w-style"] .fa-address-card-o:before{ content: "\\f2bc"; } w-style .fa-user-circle:before,[data-is="w-style"] .fa-user-circle:before{ content: "\\f2bd"; } w-style .fa-user-circle-o:before,[data-is="w-style"] .fa-user-circle-o:before{ content: "\\f2be"; } w-style .fa-user-o:before,[data-is="w-style"] .fa-user-o:before{ content: "\\f2c0"; } w-style .fa-id-badge:before,[data-is="w-style"] .fa-id-badge:before{ content: "\\f2c1"; } w-style .fa-drivers-license:before,[data-is="w-style"] .fa-drivers-license:before,w-style .fa-id-card:before,[data-is="w-style"] .fa-id-card:before{ content: "\\f2c2"; } w-style .fa-drivers-license-o:before,[data-is="w-style"] .fa-drivers-license-o:before,w-style .fa-id-card-o:before,[data-is="w-style"] .fa-id-card-o:before{ content: "\\f2c3"; } w-style .fa-quora:before,[data-is="w-style"] .fa-quora:before{ content: "\\f2c4"; } w-style .fa-free-code-camp:before,[data-is="w-style"] .fa-free-code-camp:before{ content: "\\f2c5"; } w-style .fa-telegram:before,[data-is="w-style"] .fa-telegram:before{ content: "\\f2c6"; } w-style .fa-thermometer-4:before,[data-is="w-style"] .fa-thermometer-4:before,w-style .fa-thermometer:before,[data-is="w-style"] .fa-thermometer:before,w-style .fa-thermometer-full:before,[data-is="w-style"] .fa-thermometer-full:before{ content: "\\f2c7"; } w-style .fa-thermometer-3:before,[data-is="w-style"] .fa-thermometer-3:before,w-style .fa-thermometer-three-quarters:before,[data-is="w-style"] .fa-thermometer-three-quarters:before{ content: "\\f2c8"; } w-style .fa-thermometer-2:before,[data-is="w-style"] .fa-thermometer-2:before,w-style .fa-thermometer-half:before,[data-is="w-style"] .fa-thermometer-half:before{ content: "\\f2c9"; } w-style .fa-thermometer-1:before,[data-is="w-style"] .fa-thermometer-1:before,w-style .fa-thermometer-quarter:before,[data-is="w-style"] .fa-thermometer-quarter:before{ content: "\\f2ca"; } w-style .fa-thermometer-0:before,[data-is="w-style"] .fa-thermometer-0:before,w-style .fa-thermometer-empty:before,[data-is="w-style"] .fa-thermometer-empty:before{ content: "\\f2cb"; } w-style .fa-shower:before,[data-is="w-style"] .fa-shower:before{ content: "\\f2cc"; } w-style .fa-bathtub:before,[data-is="w-style"] .fa-bathtub:before,w-style .fa-s15:before,[data-is="w-style"] .fa-s15:before,w-style .fa-bath:before,[data-is="w-style"] .fa-bath:before{ content: "\\f2cd"; } w-style .fa-podcast:before,[data-is="w-style"] .fa-podcast:before{ content: "\\f2ce"; } w-style .fa-window-maximize:before,[data-is="w-style"] .fa-window-maximize:before{ content: "\\f2d0"; } w-style .fa-window-minimize:before,[data-is="w-style"] .fa-window-minimize:before{ content: "\\f2d1"; } w-style .fa-window-restore:before,[data-is="w-style"] .fa-window-restore:before{ content: "\\f2d2"; } w-style .fa-times-rectangle:before,[data-is="w-style"] .fa-times-rectangle:before,w-style .fa-window-close:before,[data-is="w-style"] .fa-window-close:before{ content: "\\f2d3"; } w-style .fa-times-rectangle-o:before,[data-is="w-style"] .fa-times-rectangle-o:before,w-style .fa-window-close-o:before,[data-is="w-style"] .fa-window-close-o:before{ content: "\\f2d4"; } w-style .fa-bandcamp:before,[data-is="w-style"] .fa-bandcamp:before{ content: "\\f2d5"; } w-style .fa-grav:before,[data-is="w-style"] .fa-grav:before{ content: "\\f2d6"; } w-style .fa-etsy:before,[data-is="w-style"] .fa-etsy:before{ content: "\\f2d7"; } w-style .fa-imdb:before,[data-is="w-style"] .fa-imdb:before{ content: "\\f2d8"; } w-style .fa-ravelry:before,[data-is="w-style"] .fa-ravelry:before{ content: "\\f2d9"; } w-style .fa-eercast:before,[data-is="w-style"] .fa-eercast:before{ content: "\\f2da"; } w-style .fa-microchip:before,[data-is="w-style"] .fa-microchip:before{ content: "\\f2db"; } w-style .fa-snowflake-o:before,[data-is="w-style"] .fa-snowflake-o:before{ content: "\\f2dc"; } w-style .fa-superpowers:before,[data-is="w-style"] .fa-superpowers:before{ content: "\\f2dd"; } w-style .fa-wpexplorer:before,[data-is="w-style"] .fa-wpexplorer:before{ content: "\\f2de"; } w-style .fa-meetup:before,[data-is="w-style"] .fa-meetup:before{ content: "\\f2e0"; } w-style .sr-only,[data-is="w-style"] .sr-only{ position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0, 0, 0, 0); border: 0; } w-style .sr-only-focusable:active,[data-is="w-style"] .sr-only-focusable:active,w-style .sr-only-focusable:focus,[data-is="w-style"] .sr-only-focusable:focus{ position: static; width: auto; height: auto; margin: 0; overflow: visible; clip: auto; } w-style w-messaging,[data-is="w-style"] w-messaging,w-style [data-is=w-messaging],[data-is="w-style"] [data-is=w-messaging]{ position: fixed; right: 0px; top: 0px; } w-style w-messaging .message,[data-is="w-style"] w-messaging .message,w-style [data-is=w-messaging] .message,[data-is="w-style"] [data-is=w-messaging] .message{ padding: 1rem; margin-bottom: 1px; } w-style w-messaging .error,[data-is="w-style"] w-messaging .error,w-style [data-is=w-messaging] .error,[data-is="w-style"] [data-is=w-messaging] .error{ background-color: red; color: white; } w-style w-messaging .notice,[data-is="w-style"] w-messaging .notice,w-style [data-is=w-messaging] .notice,[data-is="w-style"] [data-is=w-messaging] .notice{ background-color: blue; color: white; } w-style w-modal,[data-is="w-style"] w-modal,w-style [data-is=w-modal],[data-is="w-style"] [data-is=w-modal]{ position: fixed; top: 0px; height: 100%; left: 0px; width: 100%; background-color: rgba(0, 0, 0, 0.7); z-index: 10000; } w-style w-modal [name=receiver],[data-is="w-style"] w-modal [name=receiver],w-style [data-is=w-modal] [name=receiver],[data-is="w-style"] [data-is=w-modal] [name=receiver]{ position: fixed; z-index: 10001; background-color: white; left: 50%; top: 50%; transform: translate(-50%, -50%); } w-style .kor,[data-is="w-style"] .kor{ font-family: verdana; font-size: 11px; background-color: #1e1e1e; color: #bbbbbb; } w-style .kor a,[data-is="w-style"] .kor a{ text-decoration: underline; color: #bbbbbb; } @keyframes kor-appear { from { opacity: 0; transform: translateX(100%); } to { opacity: 100; transform: translateX(0%); } } @keyframes kor-fade { from { opacity: 100; } to { opacity: 0; transform: rotateY(90deg); } } w-style #page-container,[data-is="w-style"] #page-container{ perspective: 1000px; } w-style .kor-appear-animation,[data-is="w-style"] .kor-appear-animation{ transform-style: preserve-3d; display: block; animation-name: kor-appear; animation-duration: 500ms; } w-style .kor-fade-animation,[data-is="w-style"] .kor-fade-animation{ transform-style: preserve-3d; display: block; animation-name: kor-fade; animation-duration: 500ms; } w-style kor-entity.kor-style,[data-is="w-style"] kor-entity.kor-style,w-style [data-is=kor-entity].kor-style,[data-is="w-style"] [data-is=kor-entity].kor-style{ display: inline-block; vertical-align: bottom; box-sizing: border-box; width: 200px; max-height: 200px; padding: 0.5rem; } w-style kor-entity.kor-style > a,[data-is="w-style"] kor-entity.kor-style > a,w-style [data-is=kor-entity].kor-style > a,[data-is="w-style"] [data-is=kor-entity].kor-style > a{ display: block; text-decoration: none; } w-style kor-entity.kor-style h3,[data-is="w-style"] kor-entity.kor-style h3,w-style [data-is=kor-entity].kor-style h3,[data-is="w-style"] [data-is=kor-entity].kor-style h3{ margin: 0px; color: white; } w-style kor-entity.kor-style img,[data-is="w-style"] kor-entity.kor-style img,w-style [data-is=kor-entity].kor-style img,[data-is="w-style"] [data-is=kor-entity].kor-style img{ display: block; max-width: 100%; max-height: 160px; } w-style kor-notifications ul,[data-is="w-style"] kor-notifications ul{ perspective: 1000px; position: absolute; top: 0px; right: 0px; } w-style kor-notifications ul li,[data-is="w-style"] kor-notifications ul li{ padding: 1rem; list-style-type: none; } w-style kor-search .allnone,[data-is="w-style"] kor-search .allnone,w-style [data-is=\'kor-search\'] .allnone,[data-is="w-style"] [data-is=\'kor-search\'] .allnone{ margin-right: 1rem; margin-top: -3px; }',"",function(opts){});$(document).ready(function(){$("body").append('<div data-is="w-style" style="display: none">');return riot.mount("*")});
>>>>>>> v2.1
