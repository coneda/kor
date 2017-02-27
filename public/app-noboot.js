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

(function($, undefined) {
    var prefix = "", eventPrefix, vendors = {
        Webkit: "webkit",
        Moz: "",
        O: "o"
    }, testEl = document.createElement("div"), supportedTransforms = /^((translate|rotate|scale)(X|Y|Z|3d)?|matrix(3d)?|perspective|skew(X|Y)?)$/i, transform, transitionProperty, transitionDuration, transitionTiming, transitionDelay, animationName, animationDuration, animationTiming, animationDelay, cssReset = {};
    function dasherize(str) {
        return str.replace(/([A-Z])/g, "-$1").toLowerCase();
    }
    function normalizeEvent(name) {
        return eventPrefix ? eventPrefix + name : name.toLowerCase();
    }
    if (testEl.style.transform === undefined) $.each(vendors, function(vendor, event) {
        if (testEl.style[vendor + "TransitionProperty"] !== undefined) {
            prefix = "-" + vendor.toLowerCase() + "-";
            eventPrefix = event;
            return false;
        }
    });
    transform = prefix + "transform";
    cssReset[transitionProperty = prefix + "transition-property"] = cssReset[transitionDuration = prefix + "transition-duration"] = cssReset[transitionDelay = prefix + "transition-delay"] = cssReset[transitionTiming = prefix + "transition-timing-function"] = cssReset[animationName = prefix + "animation-name"] = cssReset[animationDuration = prefix + "animation-duration"] = cssReset[animationDelay = prefix + "animation-delay"] = cssReset[animationTiming = prefix + "animation-timing-function"] = "";
    $.fx = {
        off: eventPrefix === undefined && testEl.style.transitionProperty === undefined,
        speeds: {
            _default: 400,
            fast: 200,
            slow: 600
        },
        cssPrefix: prefix,
        transitionEnd: normalizeEvent("TransitionEnd"),
        animationEnd: normalizeEvent("AnimationEnd")
    };
    $.fn.animate = function(properties, duration, ease, callback, delay) {
        if ($.isFunction(duration)) callback = duration, ease = undefined, duration = undefined;
        if ($.isFunction(ease)) callback = ease, ease = undefined;
        if ($.isPlainObject(duration)) ease = duration.easing, callback = duration.complete, 
        delay = duration.delay, duration = duration.duration;
        if (duration) duration = (typeof duration == "number" ? duration : $.fx.speeds[duration] || $.fx.speeds._default) / 1e3;
        if (delay) delay = parseFloat(delay) / 1e3;
        return this.anim(properties, duration, ease, callback, delay);
    };
    $.fn.anim = function(properties, duration, ease, callback, delay) {
        var key, cssValues = {}, cssProperties, transforms = "", that = this, wrappedCallback, endEvent = $.fx.transitionEnd, fired = false;
        if (duration === undefined) duration = $.fx.speeds._default / 1e3;
        if (delay === undefined) delay = 0;
        if ($.fx.off) duration = 0;
        if (typeof properties == "string") {
            cssValues[animationName] = properties;
            cssValues[animationDuration] = duration + "s";
            cssValues[animationDelay] = delay + "s";
            cssValues[animationTiming] = ease || "linear";
            endEvent = $.fx.animationEnd;
        } else {
            cssProperties = [];
            for (key in properties) if (supportedTransforms.test(key)) transforms += key + "(" + properties[key] + ") "; else cssValues[key] = properties[key], 
            cssProperties.push(dasherize(key));
            if (transforms) cssValues[transform] = transforms, cssProperties.push(transform);
            if (duration > 0 && typeof properties === "object") {
                cssValues[transitionProperty] = cssProperties.join(", ");
                cssValues[transitionDuration] = duration + "s";
                cssValues[transitionDelay] = delay + "s";
                cssValues[transitionTiming] = ease || "linear";
            }
        }
        wrappedCallback = function(event) {
            if (typeof event !== "undefined") {
                if (event.target !== event.currentTarget) return;
                $(event.target).unbind(endEvent, wrappedCallback);
            } else $(this).unbind(endEvent, wrappedCallback);
            fired = true;
            $(this).css(cssReset);
            callback && callback.call(this);
        };
        if (duration > 0) {
            this.bind(endEvent, wrappedCallback);
            setTimeout(function() {
                if (fired) return;
                wrappedCallback.call(that);
            }, (duration + delay) * 1e3 + 25);
        }
        this.size() && this.get(0).clientLeft;
        this.css(cssValues);
        if (duration <= 0) setTimeout(function() {
            that.each(function() {
                wrappedCallback.call(this);
            });
        }, 0);
        return this;
    };
    testEl = null;
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
    var RE_SVG_TAGS = /^(altGlyph|animate(?:Color)?|circle|clipPath|defs|ellipse|fe(?:Blend|ColorMatrix|ComponentTransfer|Composite|ConvolveMatrix|DiffuseLighting|DisplacementMap|Flood|GaussianBlur|Image|Merge|Morphology|Offset|SpecularLighting|Tile|Turbulence)|filter|font|foreignObject|g(?:lyph)?(?:Ref)?|image|line(?:arGradient)?|ma(?:rker|sk)|missing-glyph|path|pattern|poly(?:gon|line)|radialGradient|rect|stop|svg|switch|symbol|text(?:Path)?|tref|tspan|use)$/;
    var RE_HTML_ATTRS = /([-\w]+) ?= ?(?:"([^"]*)|'([^']*)|({[^}]*}))/g;
    var CASE_SENSITIVE_ATTRIBUTES = {
        viewbox: "viewBox"
    };
    var RE_BOOL_ATTRS = /^(?:disabled|checked|readonly|required|allowfullscreen|auto(?:focus|play)|compact|controls|default|formnovalidate|hidden|ismap|itemscope|loop|multiple|muted|no(?:resize|shade|validate|wrap)?|open|reversed|seamless|selected|sortable|truespeed|typemustmatch)$/;
    var IE_VERSION = (WIN && WIN.document || {}).documentMode | 0;
    function isSVGTag(name) {
        return RE_SVG_TAGS.test(name);
    }
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
        isSVGTag: isSVGTag,
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
    function mkEl(name, isSvg) {
        return isSvg ? document.createElementNS("http://www.w3.org/2000/svg", "svg") : document.createElement(name);
    }
    function getOuterHTML(el) {
        if (el.outerHTML) {
            return el.outerHTML;
        } else {
            var container = mkEl("div");
            container.appendChild(el.cloneNode(true));
            return container.innerHTML;
        }
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
        getOuterHTML: getOuterHTML,
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
        var REGLOB = "g", R_MLCOMMS = /\/\*[^*]*\*+(?:[^*\/][^*]*\*+)*\//g, R_STRINGS = /"[^"\\]*(?:\\[\S\s][^"\\]*)*"|'[^'\\]*(?:\\[\S\s][^'\\]*)*'/g, S_QBLOCKS = R_STRINGS.source + "|" + /(?:\breturn\s+|(?:[$\w\)\]]|\+\+|--)\s*(\/)(?![*\/]))/.source + "|" + /\/(?=[^*\/])[^[\/\\]*(?:(?:\[(?:\\.|[^\]\\]*)*\]|\\.)[^[\/\\]*)*?(\/)[gim]*/.source, UNSUPPORTED = RegExp("[\\" + "x00-\\x1F<>a-zA-Z0-9'\",;\\\\]"), NEED_ESCAPE = /(?=[[\]()*+?.^$|])/g, FINDBRACES = {
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
        _tmpl.version = brackets.version = "v3.0.2";
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
        for (var i = 0, el; i < len; ++i) {
            el = list[i];
            if (fn(el, i) === false) {
                i--;
            }
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
        if (!dom.addEventListener) {
            dom[name] = cb;
            return;
        }
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
            var tag = this$1.tags[tagName];
            if (isArray(tag)) {
                each(tag, function(t) {
                    moveChildTag.apply(t, [ tagName, i ]);
                });
            } else {
                moveChildTag.apply(tag, [ tagName, i ]);
            }
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
                    } else {
                        remove.apply(tags[i], [ tags, i ]);
                        oldItems.splice(i, 1);
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
    function mkdom(tmpl, html, checkSvg) {
        var match = tmpl && tmpl.match(/^\s*<([-\w]+)/), tagName = match && match[1].toLowerCase(), el = mkEl(GENERIC, checkSvg && isSVGTag(tagName));
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
        var exists = !!__TAG_IMPL[name];
        __TAG_IMPL[name] = {
            name: name,
            tmpl: tmpl,
            attrs: attrs,
            fn: fn
        };
        if (exists && util.hotReloader) {
            util.hotReloader(name);
        }
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
                var tag$$1 = mountTo(root, riotTag || root.tagName.toLowerCase(), opts);
                if (tag$$1) {
                    tags.push(tag$$1);
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
    var _id = 0;
    function mixin$1(name, mix, g) {
        if (isObject(name)) {
            mixin$1("__unnamed_" + _id++, name, true);
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
        return each(__TAGS_CACHE, function(tag$$1) {
            return tag$$1.update();
        });
    }
    function unregister$1(name) {
        delete __TAG_IMPL[name];
    }
    var core = Object.freeze({
        Tag: Tag$2,
        tag: tag$1,
        tag2: tag2$1,
        mount: mount$1,
        mixin: mixin$1,
        update: update$1,
        unregister: unregister$1
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
            updateOpts.apply(this, [ isLoop, parent, isAnonymous, nextOpts, instAttrs ]);
            if (this.isMounted && isFunction(this.shouldUpdate) && !this.shouldUpdate(data, nextOpts)) {
                return this;
            }
            data = cleanUpData(data);
            if (isLoop && isAnonymous) {
                inheritFrom.apply(this, [ this.parent, propsInSyncWithParent ]);
            }
            extend(this, data);
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
                var instance, props = [], obj;
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
                    if (key !== "init") {
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
            var _parent = this.__.parent;
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
            if (_parent && isAnonymous) {
                inheritFrom.apply(this, [ _parent, propsInSyncWithParent ]);
            }
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
    function isInStub(dom) {
        while (dom) {
            if (dom.inStub) {
                return true;
            }
            dom = dom.parentNode;
        }
        return false;
    }
    function mountTo(root, tagName, opts, ctx) {
        var impl = __TAG_IMPL[tagName], implClass = __TAG_IMPL[tagName].class, tag = ctx || (implClass ? Object.create(implClass.prototype) : {}), innerHTML = root._innerHTML = root._innerHTML || root.innerHTML;
        root.innerHTML = "";
        var conf = {
            root: root,
            opts: opts
        };
        if (opts && opts.parent) {
            conf.parent = opts.parent;
        }
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
        this.__.head = this.root.insertBefore(head, this.root.firstChild);
        this.__.tail = this.root.appendChild(tail);
        el = this.__.head;
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
        isInStub: isInStub,
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

var route = function() {
    "use strict";
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
    var RE_ORIGIN = /^.+?\/\/+[^\/]+/;
    var EVENT_LISTENER = "EventListener";
    var REMOVE_EVENT_LISTENER = "remove" + EVENT_LISTENER;
    var ADD_EVENT_LISTENER = "add" + EVENT_LISTENER;
    var HAS_ATTRIBUTE = "hasAttribute";
    var POPSTATE = "popstate";
    var HASHCHANGE = "hashchange";
    var TRIGGER = "trigger";
    var MAX_EMIT_STACK_LEVEL = 3;
    var win = typeof window != "undefined" && window;
    var doc = typeof document != "undefined" && document;
    var hist = win && history;
    var loc = win && (hist.location || win.location);
    var prot = Router.prototype;
    var clickEvent = doc && doc.ontouchstart ? "touchstart" : "click";
    var central = observable();
    var started = false;
    var routeFound = false;
    var debouncedEmit;
    var base;
    var current;
    var parser;
    var secondParser;
    var emitStack = [];
    var emitStackLevel = 0;
    function DEFAULT_PARSER(path) {
        return path.split(/[\/?#]/);
    }
    function DEFAULT_SECOND_PARSER(path, filter) {
        var f = filter.replace(/\?/g, "\\?").replace(/\*/g, "([^/?#]+?)").replace(/\.\./, ".*");
        var re = new RegExp("^" + f + "$");
        var args = path.match(re);
        if (args) {
            return args.slice(1);
        }
    }
    function debounce(fn, delay) {
        var t;
        return function() {
            clearTimeout(t);
            t = setTimeout(fn, delay);
        };
    }
    function start(autoExec) {
        debouncedEmit = debounce(emit, 1);
        win[ADD_EVENT_LISTENER](POPSTATE, debouncedEmit);
        win[ADD_EVENT_LISTENER](HASHCHANGE, debouncedEmit);
        doc[ADD_EVENT_LISTENER](clickEvent, click);
        if (autoExec) {
            emit(true);
        }
    }
    function Router() {
        this.$ = [];
        observable(this);
        central.on("stop", this.s.bind(this));
        central.on("emit", this.e.bind(this));
    }
    function normalize(path) {
        return path.replace(/^\/|\/$/, "");
    }
    function isString(str) {
        return typeof str == "string";
    }
    function getPathFromRoot(href) {
        return (href || loc.href).replace(RE_ORIGIN, "");
    }
    function getPathFromBase(href) {
        return base[0] === "#" ? (href || loc.href || "").split(base)[1] || "" : (loc ? getPathFromRoot(href) : href || "").replace(base, "");
    }
    function emit(force) {
        var isRoot = emitStackLevel === 0;
        if (MAX_EMIT_STACK_LEVEL <= emitStackLevel) {
            return;
        }
        emitStackLevel++;
        emitStack.push(function() {
            var path = getPathFromBase();
            if (force || path !== current) {
                central[TRIGGER]("emit", path);
                current = path;
            }
        });
        if (isRoot) {
            var first;
            while (first = emitStack.shift()) {
                first();
            }
            emitStackLevel = 0;
        }
    }
    function click(e) {
        if (e.which !== 1 || e.metaKey || e.ctrlKey || e.shiftKey || e.defaultPrevented) {
            return;
        }
        var el = e.target;
        while (el && el.nodeName !== "A") {
            el = el.parentNode;
        }
        if (!el || el.nodeName !== "A" || el[HAS_ATTRIBUTE]("download") || !el[HAS_ATTRIBUTE]("href") || el.target && el.target !== "_self" || el.href.indexOf(loc.href.match(RE_ORIGIN)[0]) === -1) {
            return;
        }
        if (el.href !== loc.href && (el.href.split("#")[0] === loc.href.split("#")[0] || base[0] !== "#" && getPathFromRoot(el.href).indexOf(base) !== 0 || base[0] === "#" && el.href.split(base)[0] !== loc.href.split(base)[0] || !go(getPathFromBase(el.href), el.title || doc.title))) {
            return;
        }
        e.preventDefault();
    }
    function go(path, title, shouldReplace) {
        if (!hist) {
            return central[TRIGGER]("emit", getPathFromBase(path));
        }
        path = base + normalize(path);
        title = title || doc.title;
        shouldReplace ? hist.replaceState(null, title, path) : hist.pushState(null, title, path);
        doc.title = title;
        routeFound = false;
        emit();
        return routeFound;
    }
    prot.m = function(first, second, third) {
        if (isString(first) && (!second || isString(second))) {
            go(first, second, third || false);
        } else if (second) {
            this.r(first, second);
        } else {
            this.r("@", first);
        }
    };
    prot.s = function() {
        this.off("*");
        this.$ = [];
    };
    prot.e = function(path) {
        this.$.concat("@").some(function(filter) {
            var args = (filter === "@" ? parser : secondParser)(normalize(path), normalize(filter));
            if (typeof args != "undefined") {
                this[TRIGGER].apply(null, [ filter ].concat(args));
                return routeFound = true;
            }
        }, this);
    };
    prot.r = function(filter, action) {
        if (filter !== "@") {
            filter = "/" + normalize(filter);
            this.$.push(filter);
        }
        this.on(filter, action);
    };
    var mainRouter = new Router();
    var route = mainRouter.m.bind(mainRouter);
    route.create = function() {
        var newSubRouter = new Router();
        var router = newSubRouter.m.bind(newSubRouter);
        router.stop = newSubRouter.s.bind(newSubRouter);
        return router;
    };
    route.base = function(arg) {
        base = arg || "#";
        current = getPathFromBase();
    };
    route.exec = function() {
        emit(true);
    };
    route.parser = function(fn, fn2) {
        if (!fn && !fn2) {
            parser = DEFAULT_PARSER;
            secondParser = DEFAULT_SECOND_PARSER;
        }
        if (fn) {
            parser = fn;
        }
        if (fn2) {
            secondParser = fn2;
        }
    };
    route.query = function() {
        var q = {};
        var href = loc.href || current;
        href.replace(/[?&](.+?)=([^&]*)/g, function(_, k, v) {
            q[k] = v;
        });
        return q;
    };
    route.stop = function() {
        if (started) {
            if (win) {
                win[REMOVE_EVENT_LISTENER](POPSTATE, debouncedEmit);
                win[REMOVE_EVENT_LISTENER](HASHCHANGE, debouncedEmit);
                doc[REMOVE_EVENT_LISTENER](clickEvent, click);
            }
            central[TRIGGER]("stop");
            started = false;
        }
    };
    route.start = function(autoExec) {
        if (!started) {
            if (win) {
                if (document.readyState === "complete") {
                    start(autoExec);
                } else {
                    win[ADD_EVENT_LISTENER]("load", function() {
                        setTimeout(function() {
                            start(autoExec);
                        }, 1);
                    });
                }
            }
            started = true;
        }
    };
    route.base();
    route.parser();
    return route;
}();

(function() {
    var Locales = {
        de_DE: {
            days: [ "Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag" ],
            shortDays: [ "So", "Mo", "Di", "Mi", "Do", "Fr", "Sa" ],
            months: [ "Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember" ],
            shortMonths: [ "Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez" ],
            AM: "AM",
            PM: "PM",
            am: "am",
            pm: "pm",
            formats: {
                c: "%a %d %b %Y %X %Z",
                D: "%d.%m.%Y",
                F: "%Y-%m-%d",
                R: "%H:%M",
                r: "%I:%M:%S %p",
                T: "%H:%M:%S",
                v: "%e-%b-%Y",
                X: "%T",
                x: "%D"
            }
        },
        en_CA: {
            days: [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ],
            shortDays: [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" ],
            months: [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ],
            shortMonths: [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ],
            ordinalSuffixes: [ "st", "nd", "rd", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "st", "nd", "rd", "th", "th", "th", "th", "th", "th", "th", "st" ],
            AM: "AM",
            PM: "PM",
            am: "am",
            pm: "pm",
            formats: {
                c: "%a %d %b %Y %X %Z",
                D: "%d/%m/%y",
                F: "%Y-%m-%d",
                R: "%H:%M",
                r: "%I:%M:%S %p",
                T: "%H:%M:%S",
                v: "%e-%b-%Y",
                X: "%r",
                x: "%D"
            }
        },
        en_US: {
            days: [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ],
            shortDays: [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" ],
            months: [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ],
            shortMonths: [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ],
            ordinalSuffixes: [ "st", "nd", "rd", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "st", "nd", "rd", "th", "th", "th", "th", "th", "th", "th", "st" ],
            AM: "AM",
            PM: "PM",
            am: "am",
            pm: "pm",
            formats: {
                c: "%a %d %b %Y %X %Z",
                D: "%m/%d/%y",
                F: "%Y-%m-%d",
                R: "%H:%M",
                r: "%I:%M:%S %p",
                T: "%H:%M:%S",
                v: "%e-%b-%Y",
                X: "%r",
                x: "%D"
            }
        },
        es_MX: {
            days: [ "domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado" ],
            shortDays: [ "dom", "lun", "mar", "mié", "jue", "vie", "sáb" ],
            months: [ "enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", " diciembre" ],
            shortMonths: [ "ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic" ],
            AM: "AM",
            PM: "PM",
            am: "am",
            pm: "pm",
            formats: {
                c: "%a %d %b %Y %X %Z",
                D: "%d/%m/%Y",
                F: "%Y-%m-%d",
                R: "%H:%M",
                r: "%I:%M:%S %p",
                T: "%H:%M:%S",
                v: "%e-%b-%Y",
                X: "%T",
                x: "%D"
            }
        },
        fr_FR: {
            days: [ "dimanche", "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi" ],
            shortDays: [ "dim.", "lun.", "mar.", "mer.", "jeu.", "ven.", "sam." ],
            months: [ "janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre" ],
            shortMonths: [ "janv.", "févr.", "mars", "avril", "mai", "juin", "juil.", "août", "sept.", "oct.", "nov.", "déc." ],
            AM: "AM",
            PM: "PM",
            am: "am",
            pm: "pm",
            formats: {
                c: "%a %d %b %Y %X %Z",
                D: "%d/%m/%Y",
                F: "%Y-%m-%d",
                R: "%H:%M",
                r: "%I:%M:%S %p",
                T: "%H:%M:%S",
                v: "%e-%b-%Y",
                X: "%T",
                x: "%D"
            }
        },
        it_IT: {
            days: [ "domenica", "lunedì", "martedì", "mercoledì", "giovedì", "venerdì", "sabato" ],
            shortDays: [ "dom", "lun", "mar", "mer", "gio", "ven", "sab" ],
            months: [ "gennaio", "febbraio", "marzo", "aprile", "maggio", "giugno", "luglio", "agosto", "settembre", "ottobre", "novembre", "dicembre" ],
            shortMonths: [ "pr", "mag", "giu", "lug", "ago", "set", "ott", "nov", "dic" ],
            AM: "AM",
            PM: "PM",
            am: "am",
            pm: "pm",
            formats: {
                c: "%a %d %b %Y %X %Z",
                D: "%d/%m/%Y",
                F: "%Y-%m-%d",
                R: "%H:%M",
                r: "%I:%M:%S %p",
                T: "%H:%M:%S",
                v: "%e-%b-%Y",
                X: "%T",
                x: "%D"
            }
        },
        nl_NL: {
            days: [ "zondag", "maandag", "dinsdag", "woensdag", "donderdag", "vrijdag", "zaterdag" ],
            shortDays: [ "zo", "ma", "di", "wo", "do", "vr", "za" ],
            months: [ "januari", "februari", "maart", "april", "mei", "juni", "juli", "augustus", "september", "oktober", "november", "december" ],
            shortMonths: [ "jan", "feb", "mrt", "apr", "mei", "jun", "jul", "aug", "sep", "okt", "nov", "dec" ],
            AM: "AM",
            PM: "PM",
            am: "am",
            pm: "pm",
            formats: {
                c: "%a %d %b %Y %X %Z",
                D: "%d-%m-%y",
                F: "%Y-%m-%d",
                R: "%H:%M",
                r: "%I:%M:%S %p",
                T: "%H:%M:%S",
                v: "%e-%b-%Y",
                X: "%T",
                x: "%D"
            }
        },
        pt_BR: {
            days: [ "domingo", "segunda", "terça", "quarta", "quinta", "sexta", "sábado" ],
            shortDays: [ "Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb" ],
            months: [ "janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho", "agosto", "setembro", "outubro", "novembro", "dezembro" ],
            shortMonths: [ "Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez" ],
            AM: "AM",
            PM: "PM",
            am: "am",
            pm: "pm",
            formats: {
                c: "%a %d %b %Y %X %Z",
                D: "%d-%m-%Y",
                F: "%Y-%m-%d",
                R: "%H:%M",
                r: "%I:%M:%S %p",
                T: "%H:%M:%S",
                v: "%e-%b-%Y",
                X: "%T",
                x: "%D"
            }
        },
        ru_RU: {
            days: [ "Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота" ],
            shortDays: [ "Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб" ],
            months: [ "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь" ],
            shortMonths: [ "янв", "фев", "мар", "апр", "май", "июн", "июл", "авг", "сен", "окт", "ноя", "дек" ],
            AM: "AM",
            PM: "PM",
            am: "am",
            pm: "pm",
            formats: {
                c: "%a %d %b %Y %X",
                D: "%d.%m.%y",
                F: "%Y-%m-%d",
                R: "%H:%M",
                r: "%I:%M:%S %p",
                T: "%H:%M:%S",
                v: "%e-%b-%Y",
                X: "%T",
                x: "%D"
            }
        },
        tr_TR: {
            days: [ "Pazar", "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi" ],
            shortDays: [ "Paz", "Pzt", "Sal", "Çrş", "Prş", "Cum", "Cts" ],
            months: [ "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık" ],
            shortMonths: [ "Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara" ],
            AM: "ÖÖ",
            PM: "ÖS",
            am: "ÖÖ",
            pm: "ÖS",
            formats: {
                c: "%a %d %b %Y %X %Z",
                D: "%d-%m-%Y",
                F: "%Y-%m-%d",
                R: "%H:%M",
                r: "%I:%M:%S %p",
                T: "%H:%M:%S",
                v: "%e-%b-%Y",
                X: "%T",
                x: "%D"
            }
        },
        zh_CN: {
            days: [ "星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六" ],
            shortDays: [ "日", "一", "二", "三", "四", "五", "六" ],
            months: [ "一月份", "二月份", "三月份", "四月份", "五月份", "六月份", "七月份", "八月份", "九月份", "十月份", "十一月份", "十二月份" ],
            shortMonths: [ "一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月" ],
            AM: "上午",
            PM: "下午",
            am: "上午",
            pm: "下午",
            formats: {
                c: "%a %d %b %Y %X %Z",
                D: "%d/%m/%y",
                F: "%Y-%m-%d",
                R: "%H:%M",
                r: "%I:%M:%S %p",
                T: "%H:%M:%S",
                v: "%e-%b-%Y",
                X: "%r",
                x: "%D"
            }
        }
    };
    var DefaultLocale = Locales["en_US"], defaultStrftime = new Strftime(DefaultLocale, 0, false), isCommonJS = typeof module !== "undefined", namespace;
    if (isCommonJS) {
        namespace = module.exports = defaultStrftime;
    } else {
        namespace = function() {
            return this || (1, eval)("this");
        }();
        namespace.strftime = defaultStrftime;
    }
    if (typeof Date.now !== "function") {
        Date.now = function() {
            return +new Date();
        };
    }
    function Strftime(locale, customTimezoneOffset, useUtcTimezone) {
        var _locale = locale || DefaultLocale, _customTimezoneOffset = customTimezoneOffset || 0, _useUtcBasedDate = useUtcTimezone || false, _cachedDateTimestamp = 0, _cachedDate;
        function _strftime(format, date) {
            var timestamp;
            if (!date) {
                var currentTimestamp = Date.now();
                if (currentTimestamp > _cachedDateTimestamp) {
                    _cachedDateTimestamp = currentTimestamp;
                    _cachedDate = new Date(_cachedDateTimestamp);
                    timestamp = _cachedDateTimestamp;
                    if (_useUtcBasedDate) {
                        _cachedDate = new Date(_cachedDateTimestamp + getTimestampToUtcOffsetFor(_cachedDate) + _customTimezoneOffset);
                    }
                } else {
                    timestamp = _cachedDateTimestamp;
                }
                date = _cachedDate;
            } else {
                timestamp = date.getTime();
                if (_useUtcBasedDate) {
                    var utcOffset = getTimestampToUtcOffsetFor(date);
                    date = new Date(timestamp + utcOffset + _customTimezoneOffset);
                    if (getTimestampToUtcOffsetFor(date) !== utcOffset) {
                        var newUTCOffset = getTimestampToUtcOffsetFor(date);
                        date = new Date(timestamp + newUTCOffset + _customTimezoneOffset);
                    }
                }
            }
            return _processFormat(format, date, _locale, timestamp);
        }
        function _processFormat(format, date, locale, timestamp) {
            var resultString = "", padding = null, isInScope = false, length = format.length, extendedTZ = false;
            for (var i = 0; i < length; i++) {
                var currentCharCode = format.charCodeAt(i);
                if (isInScope === true) {
                    if (currentCharCode === 45) {
                        padding = "";
                        continue;
                    } else if (currentCharCode === 95) {
                        padding = " ";
                        continue;
                    } else if (currentCharCode === 48) {
                        padding = "0";
                        continue;
                    } else if (currentCharCode === 58) {
                        if (extendedTZ) {
                            warn("[WARNING] detected use of unsupported %:: or %::: modifiers to strftime");
                        }
                        extendedTZ = true;
                        continue;
                    }
                    switch (currentCharCode) {
                      case 37:
                        resultString += "%";
                        break;

                      case 65:
                        resultString += locale.days[date.getDay()];
                        break;

                      case 66:
                        resultString += locale.months[date.getMonth()];
                        break;

                      case 67:
                        resultString += padTill2(Math.floor(date.getFullYear() / 100), padding);
                        break;

                      case 68:
                        resultString += _processFormat(locale.formats.D, date, locale, timestamp);
                        break;

                      case 70:
                        resultString += _processFormat(locale.formats.F, date, locale, timestamp);
                        break;

                      case 72:
                        resultString += padTill2(date.getHours(), padding);
                        break;

                      case 73:
                        resultString += padTill2(hours12(date.getHours()), padding);
                        break;

                      case 76:
                        resultString += padTill3(Math.floor(timestamp % 1e3));
                        break;

                      case 77:
                        resultString += padTill2(date.getMinutes(), padding);
                        break;

                      case 80:
                        resultString += date.getHours() < 12 ? locale.am : locale.pm;
                        break;

                      case 82:
                        resultString += _processFormat(locale.formats.R, date, locale, timestamp);
                        break;

                      case 83:
                        resultString += padTill2(date.getSeconds(), padding);
                        break;

                      case 84:
                        resultString += _processFormat(locale.formats.T, date, locale, timestamp);
                        break;

                      case 85:
                        resultString += padTill2(weekNumber(date, "sunday"), padding);
                        break;

                      case 87:
                        resultString += padTill2(weekNumber(date, "monday"), padding);
                        break;

                      case 88:
                        resultString += _processFormat(locale.formats.X, date, locale, timestamp);
                        break;

                      case 89:
                        resultString += date.getFullYear();
                        break;

                      case 90:
                        if (_useUtcBasedDate && _customTimezoneOffset === 0) {
                            resultString += "GMT";
                        } else {
                            var tzString = date.toString().match(/\(([\w\s]+)\)/);
                            resultString += tzString && tzString[1] || "";
                        }
                        break;

                      case 97:
                        resultString += locale.shortDays[date.getDay()];
                        break;

                      case 98:
                        resultString += locale.shortMonths[date.getMonth()];
                        break;

                      case 99:
                        resultString += _processFormat(locale.formats.c, date, locale, timestamp);
                        break;

                      case 100:
                        resultString += padTill2(date.getDate(), padding);
                        break;

                      case 101:
                        resultString += padTill2(date.getDate(), padding == null ? " " : padding);
                        break;

                      case 104:
                        resultString += locale.shortMonths[date.getMonth()];
                        break;

                      case 106:
                        var y = new Date(date.getFullYear(), 0, 1);
                        var day = Math.ceil((date.getTime() - y.getTime()) / (1e3 * 60 * 60 * 24));
                        resultString += padTill3(day);
                        break;

                      case 107:
                        resultString += padTill2(date.getHours(), padding == null ? " " : padding);
                        break;

                      case 108:
                        resultString += padTill2(hours12(date.getHours()), padding == null ? " " : padding);
                        break;

                      case 109:
                        resultString += padTill2(date.getMonth() + 1, padding);
                        break;

                      case 110:
                        resultString += "\n";
                        break;

                      case 111:
                        var day = date.getDate();
                        if (locale.ordinalSuffixes) {
                            resultString += String(day) + (locale.ordinalSuffixes[day - 1] || ordinal(day));
                        } else {
                            resultString += String(day) + ordinal(day);
                        }
                        break;

                      case 112:
                        resultString += date.getHours() < 12 ? locale.AM : locale.PM;
                        break;

                      case 114:
                        resultString += _processFormat(locale.formats.r, date, locale, timestamp);
                        break;

                      case 115:
                        resultString += Math.floor(timestamp / 1e3);
                        break;

                      case 116:
                        resultString += "	";
                        break;

                      case 117:
                        var day = date.getDay();
                        resultString += day === 0 ? 7 : day;
                        break;

                      case 118:
                        resultString += _processFormat(locale.formats.v, date, locale, timestamp);
                        break;

                      case 119:
                        resultString += date.getDay();
                        break;

                      case 120:
                        resultString += _processFormat(locale.formats.x, date, locale, timestamp);
                        break;

                      case 121:
                        resultString += ("" + date.getFullYear()).slice(2);
                        break;

                      case 122:
                        if (_useUtcBasedDate && _customTimezoneOffset === 0) {
                            resultString += extendedTZ ? "+00:00" : "+0000";
                        } else {
                            var off;
                            if (_customTimezoneOffset !== 0) {
                                off = _customTimezoneOffset / (60 * 1e3);
                            } else {
                                off = -date.getTimezoneOffset();
                            }
                            var sign = off < 0 ? "-" : "+";
                            var sep = extendedTZ ? ":" : "";
                            var hours = Math.floor(Math.abs(off / 60));
                            var mins = Math.abs(off % 60);
                            resultString += sign + padTill2(hours) + sep + padTill2(mins);
                        }
                        break;

                      default:
                        if (isInScope) {
                            resultString += "%";
                        }
                        resultString += format[i];
                        break;
                    }
                    padding = null;
                    isInScope = false;
                    continue;
                }
                if (currentCharCode === 37) {
                    isInScope = true;
                    continue;
                }
                resultString += format[i];
            }
            return resultString;
        }
        var strftime = _strftime;
        strftime.localize = function(locale) {
            return new Strftime(locale || _locale, _customTimezoneOffset, _useUtcBasedDate);
        };
        strftime.localizeByIdentifier = function(localeIdentifier) {
            var locale = Locales[localeIdentifier];
            if (!locale) {
                warn('[WARNING] No locale found with identifier "' + localeIdentifier + '".');
                return strftime;
            }
            return strftime.localize(locale);
        };
        strftime.timezone = function(timezone) {
            var customTimezoneOffset = _customTimezoneOffset;
            var useUtcBasedDate = _useUtcBasedDate;
            var timezoneType = typeof timezone;
            if (timezoneType === "number" || timezoneType === "string") {
                useUtcBasedDate = true;
                if (timezoneType === "string") {
                    var sign = timezone[0] === "-" ? -1 : 1, hours = parseInt(timezone.slice(1, 3), 10), minutes = parseInt(timezone.slice(3, 5), 10);
                    customTimezoneOffset = sign * (60 * hours + minutes) * 60 * 1e3;
                } else if (timezoneType === "number") {
                    customTimezoneOffset = timezone * 60 * 1e3;
                }
            }
            return new Strftime(_locale, customTimezoneOffset, useUtcBasedDate);
        };
        strftime.utc = function() {
            return new Strftime(_locale, _customTimezoneOffset, true);
        };
        return strftime;
    }
    function padTill2(numberToPad, paddingChar) {
        if (paddingChar === "" || numberToPad > 9) {
            return numberToPad;
        }
        if (paddingChar == null) {
            paddingChar = "0";
        }
        return paddingChar + numberToPad;
    }
    function padTill3(numberToPad) {
        if (numberToPad > 99) {
            return numberToPad;
        }
        if (numberToPad > 9) {
            return "0" + numberToPad;
        }
        return "00" + numberToPad;
    }
    function hours12(hour) {
        if (hour === 0) {
            return 12;
        } else if (hour > 12) {
            return hour - 12;
        }
        return hour;
    }
    function weekNumber(date, firstWeekday) {
        firstWeekday = firstWeekday || "sunday";
        var weekday = date.getDay();
        if (firstWeekday === "monday") {
            if (weekday === 0) weekday = 6; else weekday--;
        }
        var firstDayOfYearUtc = Date.UTC(date.getFullYear(), 0, 1), dateUtc = Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()), yday = Math.floor((dateUtc - firstDayOfYearUtc) / 864e5), weekNum = (yday + 7 - weekday) / 7;
        return Math.floor(weekNum);
    }
    function ordinal(number) {
        var i = number % 10;
        var ii = number % 100;
        if (ii >= 11 && ii <= 13 || i === 0 || i >= 4) {
            return "th";
        }
        switch (i) {
          case 1:
            return "st";

          case 2:
            return "nd";

          case 3:
            return "rd";
        }
    }
    function getTimestampToUtcOffsetFor(date) {
        return (date.getTimezoneOffset() || 0) * 6e4;
    }
    function warn(message) {
        if (typeof console !== "undefined" && typeof console.warn == "function") {
            console.warn(message);
        }
    }
})();

var indexOf = [].indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
        if (i in this && this[i] === item) return i;
    }
    return -1;
};

Zepto.extend(Zepto.ajaxSettings, {
    dataType: "json",
    contentType: "application/json",
    accept: "application/json",
    beforeSend: function(xhr, settings) {
        xhr.then(function() {
            return console.log("ajax log", xhr.requestUrl, JSON.parse(xhr.response));
        });
        xhr.requestUrl = settings.url;
        if (wApp.session.current) {
            return xhr.setRequestHeader("X-CSRF-Token", wApp.session.csrfToken());
        }
    }
});

window.wApp = {
    bus: riot.observable(),
    data: {},
    mixins: {},
    state: {},
    setup: function() {
        return [ wApp.config.setup(), wApp.session.setup(), wApp.i18n.setup(), wApp.info.setup() ];
    }
};

wApp.auth = {
    intersect: function(a, b) {
        var j, len, ref, results, value;
        if (a.length > b.length) {
            ref = [ b, a ], a = ref[0], b = ref[1];
        }
        results = [];
        for (j = 0, len = a.length; j < len; j++) {
            value = a[j];
            if (indexOf.call(b, value) >= 0) {
                results.push(value);
            }
        }
        return results;
    },
    login: function(username, password) {
        return Zepto.ajax({
            type: "post",
            url: "/login",
            data: JSON.stringify({
                username: username,
                password: password
            }),
            success: function(data) {
                wApp.session.current = data.session;
                return riot.update();
            }
        });
    },
    logout: function() {
        return Zepto.ajax({
            type: "delete",
            url: "/logout",
            success: function(data) {
                wApp.session.current = data.session;
                return riot.update();
            }
        });
    }
};

wApp.mixins.auth = {
    hasRole: function(roles) {
        var j, len, role;
        if (!this.currentUser()) {
            return false;
        }
        if (!Zepto.isArray(roles)) {
            roles = [ roles ];
        }
        for (j = 0, len = roles.length; j < len; j++) {
            role = roles[j];
            if (!this.currentUser().permissions.roles[role]) {
                return false;
            }
        }
        return true;
    },
    hasAnyRole: function() {
        var k, perms, v;
        if (!this.currentUser()) {
            return false;
        }
        perms = this.currentUser().permissions.roles;
        for (k in perms) {
            v = perms[k];
            if (v) {
                return true;
            }
        }
        return false;
    },
    allowedTo: function(policy, collections, requireAll) {
        var perms;
        if (collections == null) {
            collections = [];
        }
        if (requireAll == null) {
            requireAll = true;
        }
        if (!this.currentUser()) {
            return false;
        }
        perms = this.currentUser().permissions.collections[policy];
        if (Zepto.isArray(collections)) {
            if (collections.length === 0) {
                return perms.length > 0;
            } else {
                if (requireAll) {
                    return perms.length === collections.length && wApp.auth.intersect(perms, collections).length === perms.length;
                } else {
                    return wApp.auth.intersect(perms, collections).length > 0;
                }
            }
        } else {
            return perms.indexOf(collections) !== -1;
        }
    }
};

wApp.config = {
    setup: function() {
        return Zepto.ajax({
            url: "/config",
            success: function(data) {
                return wApp.config.data = data.config;
            }
        });
    }
};

wApp.mixins.config = {
    config: function() {
        return wApp.config.data;
    }
};

wApp.i18n = {
    setup: function() {
        return Zepto.ajax({
            url: "/translations",
            success: function(data) {
                return wApp.i18n.translations = data.translations;
            }
        });
    },
    translate: function(locale, input, options) {
        var count, error, j, key, len, part, parts, ref, ref1, regex, result, tvalue, value;
        if (options == null) {
            options = {};
        }
        if (!wApp.i18n.translations) {
            return "";
        }
        try {
            options.count || (options.count = 1);
            parts = input.split(".");
            result = wApp.i18n.translations[locale];
            for (j = 0, len = parts.length; j < len; j++) {
                part = parts[j];
                result = result[part];
            }
            count = options.count === 1 ? "one" : "other";
            result = result[count] || result;
            ref = options.values;
            for (key in ref) {
                value = ref[key];
                regex = new RegExp("%{" + key + "}", "g");
                result = result.replace(regex, value);
            }
            ref1 = options.interpolations;
            for (key in ref1) {
                value = ref1[key];
                regex = new RegExp("%{" + key + "}", "g");
                tvalue = wApp.i18n.translate(locale, value);
                if (tvalue && tvalue !== value) {
                    value = tvalue;
                }
                result = result.replace(regex, value);
            }
            if (options["capitalize"]) {
                result = result.charAt(0).toUpperCase() + result.slice(1);
            }
            return result;
        } catch (error1) {
            error = error1;
            console.log(arguments);
            console.log(error);
            return input;
        }
    },
    localize: function(locale, input, format_name) {
        var date, error, format;
        if (format_name == null) {
            format_name = "default";
        }
        try {
            if (!input) {
                return "";
            }
            format = wApp.i18n.translate(locale, "date.formats." + format_name);
            date = new Date(input);
            return strftime(format, date);
        } catch (error1) {
            error = error1;
            console.log(arguments);
            console.log(error);
            return "";
        }
    }
};

wApp.mixins.i18n = {
    t: function(input, options) {
        if (options == null) {
            options = {};
        }
        return wApp.i18n.translate(this.locale(), input, options);
    },
    tcap: function(input, options) {
        if (options == null) {
            options = {};
        }
        options["capitalize"] = true;
        return wApp.i18n.translate(this.locale(), input, options);
    },
    l: function(input, format_name) {
        return wApp.i18n.localize(this.locale(), input, format_name);
    }
};

wApp.info = {
    setup: function() {
        return Zepto.ajax({
            url: "/info",
            success: function(data) {
                return wApp.info.data = data.info;
            }
        });
    }
};

wApp.mixins.info = {
    info: function() {
        return wApp.info.data;
    },
    rootPath: function() {
        return this.info().url;
    }
};

wApp.routing = {
    query: function(params) {
        var k, qs, result, v;
        if (params) {
            result = {};
            Zepto.extend(result, wApp.routing.query(), params);
            qs = [];
            for (k in result) {
                v = result[k];
                if (result[k] !== null && result[k] !== "") {
                    qs.push(k + "=" + v);
                }
            }
            return route(wApp.routing.path() + "?" + qs.join("&"));
        } else {
            return wApp.routing.parts()["hash_query"] || {};
        }
    },
    path: function(new_path) {
        if (new_path) {
            return route(new_path);
        } else {
            return wApp.routing.parts()["hash_path"];
        }
    },
    fragment: function() {
        return window.location.hash;
    },
    back: function() {
        return window.history.back();
    },
    parts: function() {
        var cs, h, hash_query_string, j, kv, l, len, len1, pair, ref, ref1, result;
        if (!wApp.routing.parts_cache) {
            h = window.location.href;
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
        wApp.routing.route = route.create();
        route.base("#/");
        wApp.routing.route(function() {
            var old_parts;
            old_parts = wApp.routing.parts();
            if (window.location.href !== old_parts["href"]) {
                wApp.routing.parts_cache = null;
                wApp.bus.trigger("routing:href", wApp.routing.parts());
                if (old_parts["hash_path"] !== wApp.routing.path()) {
                    return wApp.bus.trigger("routing:path", wApp.routing.parts());
                } else {
                    return wApp.bus.trigger("routing:query", wApp.routing.parts());
                }
            }
        });
        route.start(true);
        return wApp.bus.trigger("routing:path", wApp.routing.parts());
    },
    tearDown: function() {
        if (wApp.routing.route) {
            return wApp.routing.route.stop();
        }
    }
};

wApp.session = {
    setup: function() {
        return Zepto.ajax({
            method: "get",
            url: "/session",
            success: function(data) {
                return wApp.session.current = data.session;
            }
        });
    },
    csrfToken: function() {
        return wApp.session.current.csrfToken;
    }
};

wApp.mixins.sessionAware = {
    session: function() {
        return wApp.session.current;
    },
    currentUser: function() {
        return this.session().user;
    },
    locale: function() {
        return this.session().locale;
    },
    isGuest: function() {
        return this.currentUser() && this.currentUser().name === "guest";
    },
    isLoggedIn: function() {
        return this.currentUser() && !this.isGuest();
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
    inGroupsOf: function(per_row, array, dummy) {
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
    toInteger: function(value) {
        if (Zepto.isNumeric(value)) {
            return parseInt(value);
        } else {
            return value;
        }
    },
    uniq: function(a) {
        var j, key, output, ref, results, value;
        output = {};
        for (key = j = 0, ref = a.length; 0 <= ref ? j < ref : j > ref; key = 0 <= ref ? ++j : --j) {
            output[a[key]] = a[key];
        }
        results = [];
        for (key in output) {
            value = output[key];
            results.push(value);
        }
        return results;
    },
    scrollToTop: function() {
        if (document.body.scrollTop !== 0 || document.documentElement.scrollTop !== 0) {
            window.scrollBy(0, -50);
            return wApp.state.scrollToTopTimeOut = setTimeout("wApp.utils.scrollToTop()", 10);
        } else {
            return clearTimeout(wApp.state.scrollToTopTimeOut);
        }
    }
};

riot.tag2("kor-about", '<div class="kor-layout-left kor-layout-large"> <div class="kor-content-box"> <div class="target"></div> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.config);
    tag.on("mount", function() {
        return Zepto(tag.root).find(".target").html(tag.config().maintainer.about_html);
    });
});

riot.tag2("kor-access-denied", '<div class="kor-layout-left kor-layout-large kor-clear-after"> <div class="kor-content-box"> <h1>{tcap(\'notices.access_denied\')}</h1> {t(\'messages.access_denied\')} <div class="hr"></div> <a href="#/login?return_to={returnTo()}">{t(\'verbs.login\')}</a> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.returnTo = function() {
        return encodeURIComponent(wApp.routing.fragment());
    };
});

riot.tag2("kor-application", '<div class="container"> <a href="#/login">login</a> <a href="#/welcome">welcome</a> <a href="#/search">search</a> <a href="#/logout">logout</a> </div> <kor-js-extensions></kor-js-extensions> <kor-router></kor-router> <kor-notifications></kor-notifications> <div id="page-container" class="container"> <kor-page class="kor-appear-animation"></kor-page> </div>', "", "", function(opts) {
    var mount_page, self;
    self = this;
    window.kor = {
        url: self.opts.baseUrl || "",
        bus: riot.observable(),
        load_session: function() {
            return $.ajax({
                type: "get",
                url: kor.url + "/api/1.0/info",
                success: function(data) {
                    kor.info = data;
                    return kor.bus.trigger("data.info");
                }
            });
        },
        login: function(username, password) {
            return $.ajax({
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
            return $.ajax({
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
    $.extend($.ajaxSettings, {
        contentType: "application/json",
        dataType: "json",
        error: function(request) {
            return kor.bus.trigger("notify", JSON.parse(request.response));
        }
    });
    mount_page = function(tag) {
        var element;
        if (self.mounted_page !== tag) {
            if (self.page_tag) {
                self.page_tag.unmount(true);
            }
            element = $(self.root).find("kor-page");
            self.page_tag = riot.mount(element[0], tag)[0];
            element.detach();
            $(self["page-container"]).append(element);
            return self.mounted_page = tag;
        }
    };
    self.on("mount", function() {
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

riot.tag2("kor-invalid-entities", '<div class="kor-layout-left kor-layout-large"> <div class="kor-content-box"> <h1>{tcap(\'nouns.invalid_entity\', {count: \'other\'})}</h1> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> <div class="hr"></div> <span show="{data && data.total == 0}"> {tcap(\'objects.none_found\', {interpolations: {o: \'nouns.entity.one\'}})} </span> <table if="{data && data.total > 0}"> <thead> <tr> <th>{tcap(\'activerecord.attributes.entity.name\')}</th> </tr> </thead> <tbody> <tr each="{entity in data.records}"> <td> <a href="#/entities/{entity.id}" class="name">{entity.display_name}</a> <span class="kind">{entity.kind.name}</span> </td> </tr> </tbody> </table> <div class="hr"></div> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var fetch, queryUpdate, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.on("mount", function() {
        var h;
        if (tag.allowedTo("delete")) {
            fetch();
            return tag.on("routing:query", fetch);
        } else {
            if (h = tag.opts.handlers.accessDenied) {
                return h();
            }
        }
    });
    fetch = function() {
        return Zepto.ajax({
            url: "/entities/invalid",
            data: {
                include: "kind",
                page: tag.opts.query.page
            },
            success: function(data) {
                tag.data = data;
                return tag.update();
            }
        });
    };
    tag.pageUpdate = function(newPage) {
        return queryUpdate({
            page: newPage
        });
    };
    queryUpdate = function(newQuery) {
        var h;
        if (h = tag.opts.handlers.queryUpdate) {
            return h(newQuery);
        }
    };
});

riot.tag2("kor-isolated-entities", '<div class="kor-content-box"> <h1>{tcap(\'nouns.isolated_entity\', {count: \'other\'})}</h1> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> <div class="hr"></div> <span show="{data && data.total == 0}"> {tcap(\'objects.none_found\', {interpolations: {o: \'nouns.entity.one\'}})} </span> <kor-gallery-grid if="{data}" entities="{data.records}"></kor-gallery-grid> <div class="hr"></div> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> </div>', "", "", function(opts) {
    var fetch, queryUpdate, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.on("mount", function() {
        var h;
        if (tag.allowedTo("edit")) {
            fetch();
            return tag.on("routing:query", fetch);
        } else {
            if (h = tag.opts.handlers.accessDenied) {
                return h();
            }
        }
    });
    fetch = function() {
        return Zepto.ajax({
            url: "/entities/isolated",
            data: {
                include: "kind",
                page: tag.opts.query.page
            },
            success: function(data) {
                tag.data = data;
                return tag.update();
            }
        });
    };
    tag.pageUpdate = function(newPage) {
        return queryUpdate({
            page: newPage
        });
    };
    queryUpdate = function(newQuery) {
        var h;
        if (h = tag.opts.handlers.queryUpdate) {
            return h(newQuery);
        }
    };
});

riot.tag2("kor-loading", "<span>... loading ...</span>", "", "", function(opts) {});

riot.tag2("kor-login", '<div class="kor-layout-left kor-layout-small"> <div class="kor-content-box"> <h1>Login</h1> <div if="{anyFederatedAuth()}"> <div class="hr"></div> <p>{t(\'prompt.federation_login\')}</p> <a href="/env_auth" class="kor-button"> {config()[\'auth\'][\'env_auth_button_label\']} </a> <div class="hr"></div> </div> <form class="form" method="POST" action="#/login" onsubmit="{submit}"> <kor-input label="{tcap(\'activerecord.attributes.user.name\')}" type="text" ref="username"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.password\')}" type="password" ref="password"></kor-input> <kor-input type="submit" riot-value="{tcap(\'verbs.login\')}"></kor-input> </form> <a href="#/password_recovery">{tcap(\'password_forgotten\')}</a> <div class="hr"></div> <strong> <span class="kor-shine">ConedaKOR</span> {t(\'nouns.version\')} <span class="kor-shine">{info().version}</span> </strong> <div class="hr silent"></div> <strong> {tcap(\'provided_by\')} <span class="kor-shine">{info().operator}</span> </strong> <div class="hr silent"></div> <strong> {tcap(\'nouns.license\')}<br> <a href="http://www.gnu.org/licenses/agpl-3.0.txt" target="_blank"> {t(\'nouns.agpl\')} </a> </strong> <div class="hr silent"></div> <strong> » <a href="{info().source_code_url}" target="_blank"> {t(\'objects.download\', {interpolations: {o: \'nouns.source_code\'}})} </a> </strong> </div> </div> <div class="kor-layout-right kor-layout-large"> <div class="kor-content-box"> <div class="kor-blend"></div> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.info);
    tag.mixin(wApp.mixins.config);
    tag.on("mount", function() {
        return Zepto(tag.root).find("input").first().focus();
    });
    tag.submit = function(event) {
        var password, username;
        event.preventDefault();
        username = tag.refs.username.value();
        password = tag.refs.password.value();
        return wApp.auth.login(username, password).then(function() {
            var parts, r;
            parts = wApp.routing.parts();
            if (r = parts.hash_query.return_to) {
                return window.location.hash = decodeURIComponent(r);
            } else {
                return wApp.bus.trigger("routing:path", wApp.routing.parts());
            }
        });
    };
    tag.anyFederatedAuth = function() {
        var k, ref, source;
        ref = tag.config().auth.sources;
        for (k in ref) {
            source = ref[k];
            if (source.type === "env") {
                return true;
            }
        }
        return false;
    };
});

riot.tag2("kor-logout", '<a href="#" onclick="{logout}"> {t(\'verbs.logout\')} </a>', "", 'show="{isLoggedIn()}"', function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.logout = function(event) {
        event.preventDefault();
        return wApp.auth.logout().then(function() {
            return wApp.bus.trigger("routing:path", wApp.routing.parts());
        });
    };
});

riot.tag2("kor-notifications", '<ul> <li each="{data in messages}" class="bg-warning {kor-fade-animation: data.remove}" onanimationend="{parent.animend}"> <i class="glyphicon glyphicon-exclamation-sign"></i> {data.message} </li> </ul>', "", "", function(opts) {
    var fading, self;
    self = this;
    self.messages = [];
    self.history = [];
    self.animend = function(event) {
        var i;
        i = self.messages.indexOf(event.item.data);
        self.history.push(self.messages[i]);
        self.messages.splice(i, 1);
        return self.update();
    };
    fading = function(data) {
        self.messages.push(data);
        self.update();
        return setTimeout(function() {
            data.remove = true;
            return self.update();
        }, 5e3);
    };
    kor.bus.on("notify", function(data) {
        var type;
        type = data.type || "default";
        if (type === "default") {
            fading(data);
        }
        return self.update();
    });
});

riot.tag2("kor-search", '<h1>Search</h1> <form class="form"> <div class="row"> <div class="col-md-3"> <div class="form-group"> <input type="text" name="terms" placeholder="fulltext search ..." class="form-control" id="kor-search-form-terms" onchange="{form_to_url}" riot-value="{params.terms}"> </div> </div> </div> <div class="row"> <div class="col-md-12 collections"> <button class="btn btn-default btn-xs allnone" onclick="{allnone}">all/none</button> <div class="checkbox-inline" each="{collection in collections}"> <label> <input type="checkbox" riot-value="{collection.id}" checked="{parent.is_collection_checked(collection)}" onchange="{parent.form_to_url}"> {collection.name} </label> </div> </div> </div> <div class="row"> <div class="col-md-12 kinds"> <button class="btn btn-default btn-xs allnone" onclick="{allnone}">all/none</button> <div class="checkbox-inline" each="{kind in kinds}"> <label> <input type="checkbox" riot-value="{kind.id}" checked="{parent.is_kind_checked(kind)}" onchange="{parent.form_to_url}"> {kind.plural_name} </label> </div> </div> </div> <div class="row"> <div class="col-md-3 kinds" each="{field in fields}"> <div class="form-group"> <input type="text" name="{field.name}" placeholder="{field.search_label}" class="kor-dataset-field form-control" id="kor-search-form-dataset-{field.name}" onchange="{parent.form_to_url}" riot-value="{parent.params.dataset[field.name]}"> </div> </div> </div> </form>', "", "", function(opts) {
    var tag;
    tag = this;
    window.x = this;
    tag.params = {};
});

riot.tag2("kor-users", '<div class="kor-content-box"> <div class="kor-layout-commands"> <a href="#/users/new"><i class="plus"></i></a> </div> <h1>{tcap(\'activerecord.models.user\', {count: \'other\'})}</h1> <form onsubmit="{search}" class="inline"> <kor-input label="{t(\'nouns.search\')}" ref="search" riot-value="{opts.query.search}"></kor-input> </form> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> <div class="hr"></div> <span show="{data && data.total == 0}"> {tcap(\'objects.none_found\', {interpolations: {o: \'nouns.entity.one\'}})} </span> <table if="{data}"> <thead> <tr> <th class="tiny">{t(\'activerecord.attributes.user.personal\')}</th> <th class="small">{t(\'activerecord.attributes.user.name\')}</th> <th class="small">{t(\'activerecord.attributes.user.full_name\')}</th> <th>{t(\'activerecord.attributes.user.email\')}</th> <th class="tiny right"> {t(\'activerecord.attributes.user.created_at\')} </th> <th class="tiny right"> {t(\'activerecord.attributes.user.last_login\')} </th> <th class="tiny right"> {t(\'activerecord.attributes.user.expires_at\')} </th> <th class="tiny buttons"></th> </tr> </thead> <tbody> <tr each="{user in data.records}"> <td><i show="{user.personal}" class="fa fa-check"></i></td> <td>{user.name}</td> <td>{user.full_name}</td> <td class="force-wrap"> <a href="mailto:{user.email}">{user.email}</a> </td> <td class="right">{l(user.created_at)}</td> <td class="right">{l(user.last_login)}</td> <td class="right">{l(user.expires_at)}</td> <td class="right nobreak"> <a onclick="{resetLoginAttempts(user.id)}"> <i class="three_bars"></i> </a> <a onclick="{resetPassword(user.id)}"> <i class="reset_password"></i> </a> <a href="#/users/{user.id}/edit"><i class="pen"></i></a> <a onclick="{destroy(user.id)}"><i class="x"></i></a> </td> </tr> </tbody> </table> <div class="hr"></div> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> </div>', "", "", function(opts) {
    var fetch, queryUpdate, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.on("mount", function() {
        var h;
        if (tag.hasRole("admin")) {
            fetch();
            return tag.on("routing:query", fetch);
        } else {
            if (h = tag.opts.handlers.accessDenied) {
                return h();
            }
        }
    });
    fetch = function(newOpts) {
        return Zepto.ajax({
            url: "/users",
            data: {
                include: "security,technical",
                search_string: tag.opts.query.search,
                page: tag.opts.query.page
            },
            success: function(data) {
                tag.data = data;
                return tag.update();
            }
        });
    };
    tag.resetLoginAttempts = function(id) {
        return function(event) {
            event.preventDefault();
            return Zepto.ajax({
                type: "PATCH",
                url: "/users/" + id + "/reset_login_attempts"
            });
        };
    };
    tag.resetPassword = function(id) {
        return function(event) {
            event.preventDefault();
            if (confirm(tag.t("confirm.sure"))) {
                return Zepto.ajax({
                    type: "PATCH",
                    url: "/users/" + id + "/reset_password"
                });
            }
        };
    };
    tag.destroy = function(id) {
        return function(event) {
            event.preventDefault();
            if (confirm(tag.t("confirm.sure"))) {
                return Zepto.ajax({
                    type: "DELETE",
                    url: "/users/" + id,
                    success: function() {
                        return fetch();
                    }
                });
            }
        };
    };
    tag.pageUpdate = function(newPage) {
        return queryUpdate({
            page: newPage
        });
    };
    tag.search = function(event) {
        event.preventDefault();
        return queryUpdate({
            page: 1,
            search: tag.refs.search.value()
        });
    };
    queryUpdate = function(newQuery) {
        var h;
        if (h = tag.opts.handlers.queryUpdate) {
            return h(newQuery);
        }
    };
});

riot.tag2("kor-welcome", '<div class="kor-content-box"> <h1>{config().app.welcome_title}</h1> <div class="target"></div> <div class="teaser" if="{currentUser()}"> <span>{t(\'pages.random_entities\')}</span> <div class="hr"></div> <kor-gallery-grid entities="{entities()}"></kor-gallery-grid> </div> </div>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.config);
    tag.on("mount", function() {
        Zepto(tag.root).find(".target").html(tag.config().app.welcome_html);
        return Zepto.ajax({
            url: "/entities/random",
            data: {
                include: "gallery_data"
            },
            success: function(data) {
                tag.data = data;
                return tag.update();
            }
        });
    });
    tag.entities = function() {
        return (tag.data || {}).records || [];
    };
});

riot.tag2("kor-gallery-grid", '<table> <tbody> <tr each="{row in inGroupsOf(4, opts.entities)}"> <td each="{entity in row}"> <virtual if="{entity.medium}"> <div class="image"> <a href="#/entities/{entity.id}"> <img riot-src="{entity.medium.url.thumbnail}"> </a> <div> {t(\'nouns.content_type\')}: <span class="content-type">{entity.medium.content_type}</span> </div> </div> <div class="meta" if="{entity.primary_entities}"> <div class="hr"></div> <div class="name"> <a each="{e in secondaries(entity)}" href="#/entities/{e.id}">{e.display_name}</a> </div> <div class="desc"> <a each="{e in primaries(entity)}" href="#/entities/{e.id}">{e.display_name}</a> </div> </div> </virtual> <div class="meta" if="{!entity.medium}"> <div class="name"> <a href="#/entities/{entity.id}">{entity.display_name}</a> </div> <div class="desc">{entity.kind.name}</div> </meta> </td> </tr> </tbody> </table>', "", "", function(opts) {
    var compare, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.inGroupsOf = wApp.utils.inGroupsOf;
    compare = function(a, b) {
        if (a.display_name < b.display_name) {
            return -1;
        }
        if (a.display_name > b.display_name) {
            return 1;
        }
        return 0;
    };
    tag.primaries = function(entity) {
        var p, results;
        results = function() {
            var i, len, ref, results1;
            ref = entity.primary_entities;
            results1 = [];
            for (i = 0, len = ref.length; i < len; i++) {
                p = ref[i];
                results1.push(p);
            }
            return results1;
        }();
        return wApp.utils.uniq(results).sort(compare);
    };
    tag.secondaries = function(entity) {
        var i, j, len, len1, p, ref, ref1, results, s;
        results = [];
        ref = entity.primary_entities;
        for (i = 0, len = ref.length; i < len; i++) {
            p = ref[i];
            ref1 = p.secondary_entities;
            for (j = 0, len1 = ref1.length; j < len1; j++) {
                s = ref1[j];
                results.push(s);
            }
        }
        return wApp.utils.uniq(results).sort(compare);
    };
});

riot.tag2("kor-input", '<label> {opts.label} <input if="{opts.type != \'select\' && opts.type != \'textarea\'}" type="{opts.type || \'text\'}" name="{opts.name}" riot-value="{value_from_parent()}" checked="{checked()}"> <textarea if="{opts.type == \'textarea\'}" name="{opts.name}" riot-value="{value_from_parent()}"></textarea> <select if="{opts.type == \'select\'}" name="{opts.name}" riot-value="{value_from_parent()}" multiple="{opts.multiple}"> <option if="{opts.placeholder}" riot-value="{0}"> {opts.placeholder} </option> <option each="{item in opts.options}" riot-value="{item.id || item.value || item}" selected="{selected(item)}"> {item.name || item.label || item} </option> </select> </label> <div class="errors" if="{opts.errors}"> <div each="{e in opts.errors}">{e}</div> </div>', "", "class=\"{'has-errors': opts.errors}\"", function(opts) {
    var tag;
    tag = this;
    tag.name = function() {
        return tag.opts.name;
    };
    tag.value = function() {
        var result;
        if (tag.opts.type === "checkbox") {
            return Zepto(tag.root).find("input").prop("checked");
        } else {
            result = Zepto(tag.root).find("input, select, textarea").val();
            if (result === "0" && tag.opts.type === "select") {
                return void 0;
            } else {
                return result;
            }
        }
    };
    tag.value_from_parent = function() {
        if (tag.opts.type === "checkbox") {
            return 1;
        } else {
            return tag.opts.riotValue;
        }
    };
    tag.checked = function() {
        return tag.opts.type === "checkbox" && tag.opts.riotValue;
    };
    tag.set = function(value) {
        if (tag.opts.type === "checkbox") {
            return Zepto(tag.root).find("input").prop("checked", !!value);
        } else {
            return Zepto(tag.root).find("input, select, textarea").val(value);
        }
    };
    tag.reset = function() {
        return tag.set(tag.value_from_parent());
    };
    tag.selected = function(item) {
        var v;
        v = item.id || item.value || item;
        if (tag.opts.multiple) {
            return (tag.value_from_parent() || []).indexOf(v) > -1;
        } else {
            return "" + v === "" + tag.value_from_parent();
        }
    };
});

riot.tag2("kor-legal", '<div class="kor-layout-left kor-layout-large"> <div class="kor-content-box"> <div class="target"></div> <div if="{!termsAccepted()}"> <div class="hr"></div> <button> {tcap(\'commands.accept_terms\')} </button> </div> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.config);
    tag.mixin(wApp.mixins.i18n);
    tag.on("mount", function() {
        return Zepto(tag.root).find(".target").html(tag.config().maintainer.legal_html);
    });
    tag.termsAccepted = function() {
        return tag.currentUser() && tag.currentUser().terms_accepted;
    };
});

riot.tag2("kor-new-media", '<div class="kor-content-box"> <h1>{tcap(\'pages.new_media\')}</h1> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> <div class="hr"></div> <span show="{data && data.total == 0}"> {tcap(\'objects.none_found\', {interpolations: {o: \'nouns.entity.one\'}})} </span> <kor-gallery-grid if="{data}" entities="{data.records}"></kor-gallery-grid> <div class="hr"></div> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> </div>', "", "", function(opts) {
    var fetch, queryUpdate, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.on("mount", function() {
        fetch();
        return tag.on("routing:query", fetch);
    });
    fetch = function() {
        return Zepto.ajax({
            url: "/entities/gallery",
            data: {
                include: "kind,gallery_data",
                page: tag.opts.query.page
            },
            success: function(data) {
                tag.data = data;
                return tag.update();
            }
        });
    };
    tag.pageUpdate = function(newPage) {
        return queryUpdate({
            page: newPage
        });
    };
    queryUpdate = function(newQuery) {
        var h;
        if (h = tag.opts.handlers.queryUpdate) {
            return h(newQuery);
        }
    };
});

riot.tag2("kor-pagination", '<span>{t(\'nouns.page\')}</span> <a show="{!isFirst()}" onclick="{toPrevious}"><i class="icon pager_left"></i></a> <kor-input riot-value="{currentPage()}" onchange="{inputChanged}" ref="manual" type="{\'number\'}"></kor-input> {t(\'of\', {values: {amount: totalPages()}})} <a show="{!isLast()}" onclick="{toNext}"><i class="icon pager_right"></i></a>', "", 'show="{isActive()}"', function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.currentPage = function() {
        return parseInt(tag.opts.page || 1);
    };
    tag.toFirst = function(event) {
        if (event) {
            event.preventDefault();
        }
        return tag.to(1);
    };
    tag.toNext = function(event) {
        if (event) {
            event.preventDefault();
        }
        return tag.to(tag.currentPage() + 1);
    };
    tag.toPrevious = function(event) {
        if (event) {
            event.preventDefault();
        }
        return tag.to(tag.currentPage() - 1);
    };
    tag.toLast = function(event) {
        if (event) {
            event.preventDefault();
        }
        return tag.to(tag.totalPages());
    };
    tag.isFirst = function() {
        return tag.currentPage() === 1;
    };
    tag.isLast = function() {
        return tag.currentPage() === tag.totalPages();
    };
    tag.to = function(new_page) {
        if (new_page !== tag.currentPage() && new_page >= 1 && new_page <= tag.totalPages()) {
            if (Zepto.isFunction(tag.opts.pageUpdateHandler)) {
                return tag.opts.pageUpdateHandler(new_page);
            }
        }
    };
    tag.totalPages = function() {
        return Math.ceil(tag.opts.total / tag.opts.perPage);
    };
    tag.inputChanged = function(event) {
        return tag.to(parseInt(tag.refs.manual.value()));
    };
    tag.isActive = function() {
        return tag.opts.total && tag.opts.total > tag.opts.perPage;
    };
});

riot.tag2("kor-profile", '<div class="kor-layout-left kor-layout-large" show="{loaded}"> <div class="kor-content-box"> <h1>{tcap(\'objects.edit\', {interpolations: {o: \'nouns.profile\'}})}</h1> <form onsubmit="{submit}" if="{data}"> <kor-input label="{tcap(\'activerecord.attributes.user.full_name\')}" name="full_name" ref="fields" riot-value="{data.full_name}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.name\')}" name="name" ref="fields" riot-value="{data.name}" errors="{errors.name}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.email\')}" name="email" ref="fields" riot-value="{data.email}" errors="{errors.email}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.password\')}" name="password" type="password" ref="fields" riot-value="{data.password}" errors="{errors.password}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.plain_password_confirmation\')}" name="plain_password_confirmation" type="password" ref="fields" errors="{errors.plain_password_confirmation}"></kor-input> <div class="hr"></div> <kor-input label="{tcap(\'activerecord.attributes.user.api_key\')}" name="api_key" type="textarea" ref="fields" riot-value="{data.api_key}" errors="{errors.api_key}"></kor-input> <div class="hr"></div> <kor-input label="{tcap(\'activerecord.attributes.user.locale\')}" name="locale" type="select" options="{[\'de\', \'en\']}" ref="fields" riot-value="{data.locale}"></kor-input> <div class="hr"></div> <kor-input if="{collections}" label="{tcap(\'activerecord.attributes.user.default_collection_id\')}" name="default_collection_id" type="select" options="{collections.records}" ref="fields" riot-value="{data.default_collection_id}"></kor-input> <div class="hr"></div> <kor-input type="submit" riot-value="{tcap(\'verbs.save\')}"></kor-input> </form> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var expiresAtTag, fetchCollections, fetchUser, tag, update, values;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.on("mount", function() {
        var h;
        tag.errors = {};
        if (tag.currentUser() && !tag.isGuest()) {
            return Zepto.when(fetchCollections(), fetchUser()).then(function() {
                tag.loaded = true;
                return tag.update();
            });
        } else {
            if (h = tag.opts.handlers.accessDenied) {
                return h();
            }
        }
    });
    tag.submit = function(event) {
        var p;
        event.preventDefault();
        p = update();
        p.done(function(data) {
            return tag.errors = {};
        });
        p.fail(function(xhr) {
            tag.errors = JSON.parse(xhr.responseText).errors;
            return wApp.utils.scrollToTop();
        });
        return p.always(function() {
            return tag.update();
        });
    };
    tag.expiresIn = function(days) {
        return function(event) {
            var date;
            if (days) {
                date = new Date();
                date.setTime(date.getTime() + days * 24 * 60 * 60 * 1e3);
                return expiresAtTag().set(strftime("%Y-%m-%d", date));
            } else {
                return expiresAtTag().set(void 0);
            }
        };
    };
    tag.valueForDate = function(date) {
        if (date) {
            return strftime("%Y-%m-%d", new Date(date));
        } else {
            return "";
        }
    };
    fetchUser = function() {
        return Zepto.ajax({
            url: "/users/" + tag.currentUser().id,
            data: {
                include: "security"
            },
            success: function(data) {
                tag.data = data;
                return tag.update();
            }
        });
    };
    fetchCollections = function() {
        return Zepto.ajax({
            url: "/collections",
            success: function(data) {
                tag.collections = data;
                return tag.update();
            }
        });
    };
    update = function() {
        return Zepto.ajax({
            type: "PATCH",
            url: "/profile",
            data: JSON.stringify({
                id: tag.currentUser().id,
                user: values()
            })
        });
    };
    expiresAtTag = function() {
        var f, i, len, ref;
        ref = tag.refs.fields;
        for (i = 0, len = ref.length; i < len; i++) {
            f = ref[i];
            if (f.name() === "expires_at") {
                return f;
            }
        }
        return void 0;
    };
    values = function() {
        var f, i, len, ref, results;
        results = {};
        ref = tag.refs.fields;
        for (i = 0, len = ref.length; i < len; i++) {
            f = ref[i];
            results[f.name()] = f.value();
        }
        return results;
    };
});

riot.tag2("kor-recent-entities", '<div class="kor-layout-left kor-layout-large" show="{loaded}"> <div class="kor-content-box"> <h1>{tcap(\'nouns.new_entity\', {count: \'other\'})}</h1> <form> <kor-input if="{collections}" label="{tcap(\'activerecord.attributes.entity.collection_id\')}" type="select" options="{collections.records}" placeholder="{t(\'prompts.please_select\')}" onchange="{collectionSelected}" ref="collectionId" riot-value="{opts.query.collection_id}"></kor-input> </form> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> <div class="hr"></div> <span show="{data && data.total == 0}"> {tcap(\'objects.none_found\', {interpolations: {o: \'nouns.entity.one\'}})} </span> <table if="{data && data.total > 0}"> <thead> <tr> <th>{tcap(\'activerecord.attributes.entity.name\')}</th> <th>{tcap(\'activerecord.attributes.entity.collection_id\')}</th> <th>{tcap(\'activerecord.attributes.entity.updater\')}</th> </tr> </thead> <tbody> <tr each="{entity in data.records}"> <td> <a href="#/entities/{entity.id}" class="name">{entity.display_name}</a> <span class="kind">{entity.kind.name}</span> </td> <td> {entity.collection.name} </td> <td> {(entity.updater || entity.creator || {}).full_name} </td> </tr> </tbody> </table> <div class="hr"></div> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var fetch, fetchCollections, queryUpdate, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.on("mount", function() {
        var h;
        if (tag.allowedTo("edit")) {
            Zepto.when(fetchCollections(), fetch()).then(function() {
                tag.loaded = true;
                return tag.update();
            });
            return tag.on("routing:query", fetch);
        } else {
            if (h = tag.opts.handlers.accessDenied) {
                return h();
            }
        }
    });
    fetch = function() {
        return Zepto.ajax({
            url: "/entities/recent",
            data: {
                include: "kind,users,collection",
                page: tag.opts.query.page,
                collection_id: tag.opts.query.collection_id
            },
            success: function(data) {
                tag.data = data;
                return tag.update();
            }
        });
    };
    fetchCollections = function() {
        return Zepto.ajax({
            url: "/collections",
            success: function(data) {
                tag.collections = data;
                return tag.update();
            }
        });
    };
    tag.pageUpdate = function(newPage) {
        return queryUpdate({
            page: newPage
        });
    };
    tag.collectionSelected = function(event) {
        return queryUpdate({
            page: 1,
            collection_id: tag.refs.collectionId.value()
        });
    };
    queryUpdate = function(newQuery) {
        var h;
        if (h = tag.opts.handlers.queryUpdate) {
            return h(newQuery);
        }
    };
});

riot.tag2("kor-entity", '<div class="auth" if="{!authorized}"> <strong>Info</strong> <p> It seems you are not allowed to see this content. Please <a href="{login_url()}">login</a> to the kor installation first. </p> </div> <a href="{url()}" if="{authorized}" target="_blank"> <img if="{data.medium}" riot-src="{image_url()}"> <div if="{!data.medium}"> <h3>{data.display_name}</h3> <em if="{include(\'kind\')}"> {data.kind_name} <span show="{data.subtype}">({data.subtype})</span> </em> </div> </a>', "", "class=\"{'kor-style': opts.korStyle, 'kor': opts.korStyle}\"", function(opts) {
    var self;
    self = this;
    self.authorized = true;
    self.on("mount", function() {
        var base;
        if (self.opts.id) {
            base = $("script[kor-url]").attr("kor-url") || "";
            return $.ajax({
                type: "get",
                url: base + "/entities/" + self.opts.id,
                data: {
                    include: "all"
                },
                dataType: "json",
                beforeSend: function(xhr) {
                    return xhr.withCredentials = true;
                },
                success: function(data) {
                    self.data = data;
                    return self.update();
                },
                error: function(request) {
                    self.data = {};
                    if (request.status === 403) {
                        self.authorized = false;
                        return self.update();
                    }
                }
            });
        } else {
            return raise("this widget requires an id");
        }
    });
    self.login_url = function() {
        var base, return_to;
        base = $("script[kor-url]").attr("kor-url") || "";
        return_to = document.location.href;
        return base + "/login?return_to=" + return_to;
    };
    self.image_size = function() {
        return self.opts.korImageSize || "preview";
    };
    self.image_url = function() {
        var base, size;
        base = $("script[kor-url]").attr("kor-url") || "";
        size = self.image_size();
        return "" + base + self.data.medium.url[size];
    };
    self.include = function(what) {
        var includes;
        includes = (self.opts.korInclude || "").split(/\s+/);
        return includes.indexOf(what) !== -1;
    };
    self.url = function() {
        var base;
        base = $("[kor-url]").attr("kor-url") || "";
        return base + "/blaze#/entities/" + self.data.id;
    };
    self.human_size = function() {
        var size;
        size = self.data.medium.file_size / 1024 / 1024;
        return Math.floor(size * 100) / 100;
    };
});

riot.tag2("kor-stats", "<h1>STATS</h1>", "", "", function(opts) {});

riot.tag2("kor-user-editor", '<div class="kor-layout-left kor-layout-large" show="{loaded}"> <div class="kor-content-box"> <h1 show="{opts.id}"> {tcap(\'objects.edit\', {interpolations: {o: \'activerecord.models.user\'}})} </h1> <h1 show="{!opts.id}"> {tcap(\'objects.new\', {interpolations: {o: \'activerecord.models.user\'}})} </h1> <form onsubmit="{submit}" if="{data}"> <kor-input label="{tcap(\'activerecord.attributes.user.personal\')}" name="make_personal" type="checkbox" riot-value="{data.personal}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.full_name\')}" name="full_name" ref="fields" riot-value="{data.full_name}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.name\')}" name="name" ref="fields" riot-value="{data.name}" errors="{errors.name}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.email\')}" name="email" ref="fields" riot-value="{data.email}" errors="{errors.email}"></kor-input> <div class="hr"></div> <kor-input label="{tcap(\'activerecord.attributes.user.api_key\')}" name="api_key" type="textarea" ref="fields" riot-value="{data.api_key}" errors="{errors.api_key}"></kor-input> <div class="hr"></div> <kor-input label="{tcap(\'activerecord.attributes.user.active\')}" name="active" type="checkbox" ref="fields" riot-value="{data.active}"></kor-input> <div class="expires-at"> <kor-input label="{tcap(\'activerecord.attributes.user.expires_at\')}" name="expires_at" ref="fields" riot-value="{valueForDate(data.expires_at)}" errors="{errors.expires_at}" type="{\'date\'}"></kor-input> <button onclick="{expiresIn(0)}"> {tcap(\'activerecord.attributes.user.does_not_expire\')} </button> <button onclick="{expiresIn(7)}"> {tcap(\'activerecord.attributes.user.expires_in_days\', {values: {amount: 7}})} </button> <button onclick="{expiresIn(30)}"> {tcap(\'activerecord.attributes.user.expires_in_days\', {values: {amount: 30}})} </button> <button onclick="{expiresIn(180)}"> {tcap(\'activerecord.attributes.user.expires_in_days\', {values: {amount: 180}})} </button> <div class="clearfix"></div> </div> <div class="hr"></div> <kor-input if="{credentials}" label="{tcap(\'activerecord.attributes.user.groups\')}" name="group_ids" type="select" options="{credentials.records}" multiple="{true}" ref="fields" riot-value="{data.group_ids}"></kor-input> <div class="hr"></div> <kor-input label="{tcap(\'activerecord.attributes.user.authority_group_admin\')}" name="authority_group_admin" type="checkbox" ref="fields" riot-value="{data.authority_group_admin}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.relation_admin\')}" name="relation_admin" type="checkbox" ref="fields" riot-value="{data.relation_admin}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.kind_admin\')}" name="kind_admin" type="checkbox" ref="fields" riot-value="{data.kind_admin}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.admin\')}" name="admin" type="checkbox" ref="fields" riot-value="{data.admin}"></kor-input> <div class="hr"></div> <kor-input type="submit" riot-value="{tcap(\'verbs.save\')}"></kor-input> </form> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var create, expiresAtTag, fetchCredentials, fetchUser, tag, update, values;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.on("mount", function() {
        var h;
        tag.errors = {};
        if (tag.hasRole("admin")) {
            return Zepto.when(fetchCredentials(), fetchUser()).then(function() {
                tag.loaded = true;
                return tag.update();
            });
        } else {
            if (h = tag.opts.handlers.accessDenied) {
                return h();
            }
        }
    });
    tag.submit = function(event) {
        var p;
        event.preventDefault();
        p = tag.opts.id ? update() : create();
        p.done(function(data) {
            var h;
            if (h = tag.opts.handlers.doneHandler) {
                return h();
            }
        });
        p.fail(function(xhr) {
            tag.errors = JSON.parse(xhr.responseText).errors;
            return wApp.utils.scrollToTop();
        });
        return p.always(function() {
            return tag.update();
        });
    };
    tag.expiresIn = function(days) {
        return function(event) {
            var date;
            if (days) {
                date = new Date();
                date.setTime(date.getTime() + days * 24 * 60 * 60 * 1e3);
                return expiresAtTag().set(strftime("%Y-%m-%d", date));
            } else {
                return expiresAtTag().set(void 0);
            }
        };
    };
    tag.valueForDate = function(date) {
        if (date) {
            return strftime("%Y-%m-%d", new Date(date));
        } else {
            return "";
        }
    };
    fetchCredentials = function() {
        return Zepto.ajax({
            url: "/credentials",
            success: function(data) {
                tag.credentials = data;
                return tag.update();
            }
        });
    };
    fetchUser = function() {
        if (tag.opts.id) {
            return Zepto.ajax({
                url: "/users/" + tag.opts.id,
                data: {
                    include: "security"
                },
                success: function(data) {
                    tag.data = data;
                    return tag.update();
                }
            });
        } else {
            tag.data = {};
            return tag.update();
        }
    };
    create = function() {
        return Zepto.ajax({
            type: "POST",
            url: "/users",
            data: JSON.stringify({
                user: values()
            })
        });
    };
    update = function() {
        return Zepto.ajax({
            type: "PATCH",
            url: "/users/" + tag.opts.id,
            data: JSON.stringify({
                user: values()
            })
        });
    };
    expiresAtTag = function() {
        var f, i, len, ref;
        ref = tag.refs.fields;
        for (i = 0, len = ref.length; i < len; i++) {
            f = ref[i];
            if (f.name() === "expires_at") {
                return f;
            }
        }
        return void 0;
    };
    values = function() {
        var f, i, len, ref, results;
        results = {};
        ref = tag.refs.fields;
        for (i = 0, len = ref.length; i < len; i++) {
            f = ref[i];
            results[f.name()] = f.value();
        }
        return results;
    };
});

riot.tag2("w-app-loader", '<div class="app"></div>', "", "", function(opts) {
    var reloadApp, tag;
    tag = this;
    reloadApp = function() {
        var preloaders;
        if (tag.mountedApp) {
            tag.mountedApp.unmount(true);
        }
        preloaders = wApp.setup();
        return $.when.apply($, preloaders).then(function() {
            var element, opts;
            element = Zepto(tag.root).find(".app")[0];
            opts = {
                routing: true
            };
            tag.mountedApp = riot.mount(element, "w-app", opts)[0];
            return console.log("application (re)loaded");
        });
    };
    wApp.bus.on("reload-app", reloadApp);
    tag.on("mount", function() {
        return wApp.bus.trigger("reload-app");
    });
});

riot.tag2("w-app", '<kor-header></kor-header> <div> <kor-menu></kor-menu> <div class="w-content" ref="content"></div> </div> <w-modal></w-modal> <w-messaging></w-messaging>', "", "", function(opts) {
    var redirectTo, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.auth);
    tag.on("mount", function() {
        wApp.bus.on("routing:path", tag.routeHandler);
        wApp.bus.on("routing:query", tag.queryHandler);
        if (tag.opts.routing) {
            return wApp.routing.setup();
        }
    });
    tag.on("unmount", function() {
        wApp.bus.off("routing:query", tag.queryHandler);
        wApp.bus.off("routing:path", tag.routeHandler);
        if (tag.opts.routing) {
            return wApp.routing.tearDown();
        }
    });
    tag.routeHandler = function(parts) {
        var m, opts, path, tagName;
        tagName = "kor-loading";
        opts = {
            query: parts["hash_query"],
            handlers: {
                accessDenied: function() {
                    return tag.mountTag("kor-access-denied");
                },
                queryUpdate: function(newQuery) {
                    return wApp.routing.query(newQuery);
                },
                doneHandler: function() {
                    return wApp.routing.back();
                }
            }
        };
        path = parts["hash_path"];
        tagName = function() {
            switch (path) {
              case void 0:
              case "":
              case "/":
                return "kor-welcome";

              case "/login":
                if (tag.currentUser() && !tag.isGuest()) {
                    return redirectTo("/search");
                } else {
                    return "kor-login";
                }
                break;

              case "/stats":
                return "kor-stats";

              case "/legal":
                return "kor-legal";

              case "/about":
                return "kor-about";

              default:
                if (tag.currentUser()) {
                    if (!tag.isGuest() && !tag.currentUser().terms_accepted && path !== "/legal") {
                        return redirectTo("/legal");
                    } else {
                        if (m = path.match(/\/users\/([0-9]+)\/edit/)) {
                            opts["id"] = parseInt(m[1]);
                            return "kor-user-editor";
                        } else {
                            switch (path) {
                              case "/profile":
                                return "kor-profile";

                              case "/search":
                                return "kor-search";

                              case "/new-media":
                                return "kor-new-media";

                              case "/users/new":
                                return "kor-user-editor";

                              case "/users":
                                return "kor-users";

                              case "/entities/invalid":
                                return "kor-invalid-entities";

                              case "/entities/recent":
                                return "kor-recent-entities";

                              case "/entities/isolated":
                                return "kor-isolated-entities";

                              default:
                                return "kor-search";
                            }
                        }
                    }
                } else {
                    return "kor-login";
                }
            }
        }();
        return tag.mountTagAndAnimate(tagName, opts);
    };
    tag.queryHandler = function(parts) {
        if (tag.mountedTag) {
            tag.mountedTag.opts.query = parts["hash_query"];
            return tag.mountedTag.trigger("routing:query");
        }
    };
    tag.mountTagAndAnimate = function(tagName, opts) {
        var element, mountIt;
        if (opts == null) {
            opts = {};
        }
        if (tagName) {
            element = Zepto(".w-content");
            mountIt = function() {
                tag.mountedTag = riot.mount(element[0], tagName, opts)[0];
                element.animate({
                    opacity: 1
                }, 200);
                return wApp.utils.scrollToTop();
            };
            if (tag.mountedTag) {
                return element.animate({
                    opacity: 0
                }, 200, function() {
                    tag.mountedTag.unmount(true);
                    return mountIt();
                });
            } else {
                return mountIt();
            }
        }
    };
    tag.mountTag = function(tagName, opts) {
        var element;
        if (opts == null) {
            opts = {};
        }
        if (tagName) {
            element = Zepto(".w-content");
            if (tag.mountedTag) {
                tag.mountedTag.unmount(true);
            }
            tag.mountedTag = riot.mount(element[0], tagName, opts)[0];
            return wApp.utils.scrollToTop();
        }
    };
    redirectTo = function(new_path) {
        wApp.routing.path(new_path);
        return null;
    };
});

riot.tag2("w-bar-chart", '<svg riot-width="{width()}" riot-height="{height()}"> <rect class="bg" riot-width="{width()}" riot-height="{height()}"></rect> <g each="{value, i in sortedItems()}"> <rect class="bar" x="0" riot-y="{yFor(i)}" height="30" riot-width="{widthPercentFor(value)}%"></rect> <text x="5" riot-y="{yForText(i)}" class="label"> {value.label} ({value.value}) </text> </g> </svg>', "", "", function(opts) {
    var base, max, tag;
    tag = this;
    (base = tag.opts).items || (base.items = []);
    max = 0;
    tag.max = function() {
        var v;
        return max || (max = opts.items.length > 0 ? Math.max.apply(Math, function() {
            var j, len, ref, results;
            ref = opts.items;
            results = [];
            for (j = 0, len = ref.length; j < len; j++) {
                v = ref[j];
                results.push(v.value);
            }
            return results;
        }()) : 0);
    };
    tag.width = function() {
        return tag.opts.width || "100%";
    };
    tag.height = function() {
        return Math.max(tag.opts.items.length * 35 - 5, 0);
    };
    tag.widthPercentFor = function(value) {
        return value.value / tag.max() * 100;
    };
    tag.sortedItems = function() {
        return tag.opts.items.sort(function(a, b) {
            return b.value - a.value;
        });
    };
    tag.yFor = function(i) {
        return i * (30 + 5);
    };
    tag.yForText = function(i) {
        return 20 + i * (30 + 5);
    };
});

riot.tag2("kor-header", '<a href="#/" class="logo"> <img src="images/logo.gif"> </a> <div class="session"> <span> <strong>ConedaKOR</strong> {t(\'nouns.version\')} {info().version} </span> <span if="{currentUser()}"> <img src="images/vertical_dots.gif"> {t(\'logged_in_as\')}: <strong>{currentUser().display_name}</strong> <span if="{!isGuest()}"> <img src="images/vertical_dots.gif"> <kor-logout></kor-logout> </span> </span> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.info);
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
});

riot.tag2("kor-menu", '<ul> <li show="{!isLoggedIn()}"> <a href="#/login">{tcap(\'nouns.login\')}</a> </li> <li show="{isLoggedIn()}"> <a href="#/profile">{tcap(\'edit_self\')}</a> </li> <li show="{isLoggedIn()}"> <a href="#/clipboard">{tcap(\'nouns.clipboard\')}</a> </li> </ul> <ul show="{currentUser()}"> <li> <a href="#/new-media">{tcap(\'pages.new_media\')}</a> </li> <li> <a href="#/search">{tcap(\'nouns.simple_search\')}</a> </li> <li> <a href="#/search">{tcap(\'nouns.expert_search\')}</a> </li> </ul> <ul show="{currentUser()}"> <li> <a href="#" onclick="{toggleGroups}"> {tcap(\'nouns.group\', {count: \'other\'})} </a> <ul show="{showGroups}" class="submenu"> <li> <a href="#/groups/authority"> {tcap(\'activerecord.models.authority_group.other\')} </a> </li> <li show="{isLoggedIn()}"> <a href="#/groups/user"> {tcap(\'activerecord.models.user_group.other\')} </a> </li> <li show="{isLoggedIn()}"> <a href="#/groups/shared"> {tcap(\'activerecord.attributes.user_group.shared\')} </a> </li> <li show="{isLoggedIn()}"> <a href="#/groups/published"> {tcap(\'activerecord.attributes.user_group.shared\')} </a> </li> </ul> </li> </ul> <ul show="{isLoggedIn() && allowedTo(\'create\')}"> <li> <kor-input if="{kinds}" type="select" onchange="{newEntity}" options="{kinds.records}" placeholder="{tcap(\'objects.new\', {interpolations: {o: \'nouns.entity\'}})}" ref="kind_id"></kor-input> </li> <li show="{isLoggedIn()}"> <a href="#/upload">{tcap(\'nouns.mass_upload\')}</a> </li> </ul> <ul show="{isLoggedIn()}"> <li show="{allowedTo(\'delete\')}"> <a href="#/entities/invalid">{tcap(\'nouns.invalid_entity\', {count: \'other\'})}</a> </li> <li show="{allowedTo(\'edit\')}"> <a href="#/entities/recent">{tcap(\'nouns.new_entity\', {count: \'other\'})}</a> </li> <li show="{allowedTo(\'edit\')}"> <a href="#/entities/isolated">{tcap(\'nouns.isolated_entity\', {count: \'other\'})}</a> </li> </ul> <ul show="{hasAnyRole()}"> <li> <a href="#" onclick="{toggleConfig}"> {tcap(\'nouns.config\', {count: \'other\'})} </a> <ul show="{showConfig}" class="submenu"> <li show="{hasRole(\'admin\')}"> <a href="#/config/general"> {tcap(\'general\')} </a> </li> <li show="{hasRole(\'relation_admin\')}"> <a href="#/relations"> {tcap(\'activerecord.models.relation.other\')} </a> </li> <li show="{hasRole(\'kind_admin\')}"> <a href="#/kinds"> {tcap(\'activerecord.models.kind.other\')} </a> </li> <li show="{hasRole(\'admin\')}"> <a href="#/collections"> {tcap(\'activerecord.models.collection.other\')} </a> </li> <li show="{hasRole(\'admin\')}"> <a href="#/credentials"> {tcap(\'activerecord.models.credential.other\')} </a> </li> <li show="{hasRole(\'admin\')}"> <a href="#/users"> {tcap(\'activerecord.models.user.other\')} </a> </li> </ul> </li> </ul> <ul> <li> <a href="#/stats">{tcap(\'nouns.statistics\')}</a> </li> <li show="{hasRole(\'admin\')}"> <a href="#/dev">{tcap(\'activerecord.models.exception_log.other\')}</a> </li> </ul> <ul> <li> <a href="#/legal">{tcap(\'legal\')}</a> </li> <li> <a href="#/about">{tcap(\'about\')}</a> </li> <li> <a href="https://coneda.net" target="_blank">coneda.net</a> </li> </ul> <ul> <li show="{hasAnyRole()}"> <a href="https://github.com/coneda/kor/issues"> {tcap(\'report_a_problem\')} </a> </li> <li hide="{hasAnyRole()}"> <a href="mailto:{config().maintainer.mail}"> {tcap(\'report_a_problem\')} </a> </li> </ul>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.config);
    tag.on("mount", function() {
        return $.ajax({
            url: "/kinds",
            success: function(data) {
                tag.kinds = data;
                return tag.update();
            }
        });
    });
    tag.toggleGroups = function(event) {
        event.preventDefault();
        tag.showGroups = !tag.showGroups;
        return tag.update();
    };
    tag.toggleConfig = function(event) {
        event.preventDefault();
        tag.showConfig = !tag.showConfig;
        return tag.update();
    };
    tag.newEntity = function(event) {
        var kind_id;
        event.preventDefault();
        kind_id = tag.refs.kind_id.value();
        wApp.routing.path("/entities/new?kind_id=" + kind_id);
        return tag.refs.kind_id.set(0);
    };
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

riot.tag2("w-modal", '<div class="receiver" ref="receiver"></div>', "", 'show="{active}"', function(opts) {
    var tag;
    tag = this;
    tag.active = false;
    tag.mountedTag = null;
    wApp.bus.on("modal", function(tagName, opts) {
        if (opts == null) {
            opts = {};
        }
        opts.modal = tagName;
        tag.mountedTag = riot.mount(tag.refs.receiver, tagName, opts)[0];
        tag.active = true;
        return tag.update();
    });
    Zepto(document).on("keydown", function(event) {
        if (tag.active && event.key === "Escape") {
            return tag.trigger("close");
        }
    });
    tag.on("mount", function() {
        return Zepto(tag.root).on("click", function(event) {
            if (tag.active && event.target === tag.root) {
                return tag.trigger("close");
            }
        });
    });
    tag.on("close", function() {
        if (tag.active) {
            tag.active = false;
            tag.mountedTag.unmount(true);
            return tag.update();
        }
    });
});

riot.tag2("w-pagination", '<div class="w-text-right" show="{total_pages() > 1}"> <a show="{!is_first()}" onclick="{page_to_first}"><i class="fa fa-angle-double-left"></i></a> <a show="{!is_first()}" onclick="{page_down}"><i class="fa fa-angle-left"></i></a> {opts.page}/{total_pages()} <a show="{!is_last()}" onclick="{page_up}"><i class="fa fa-angle-right"></i></a> <a show="{!is_last()}" onclick="{page_to_last}"><i class="fa fa-angle-double-right"></i></a> </div>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.current_page = function() {
        return parseInt(wApp.routing.query()["page"] || 1);
    };
    tag.page_to_first = function() {
        return tag.page_to(1);
    };
    tag.page_down = function() {
        return tag.page_to(tag.current_page() - 1);
    };
    tag.page_up = function() {
        return tag.page_to(tag.current_page() + 1);
    };
    tag.page_to_last = function() {
        return tag.page_to(tag.total_pages());
    };
    tag.is_first = function() {
        return tag.current_page() === 1;
    };
    tag.is_last = function() {
        return tag.current_page() === tag.total_pages();
    };
    tag.page_to = function(new_page) {
        if (new_page !== tag.current_page() && new_page >= 1 && new_page <= tag.total_pages()) {
            return wApp.routing.query({
                page: new_page
            });
        }
    };
    tag.total_pages = function() {
        return Math.ceil(tag.opts.total / tag.opts.per_page);
    };
});

riot.tag2("w-timestamp", "<span>{formatted()}</span>", "", "", function(opts) {
    var tag;
    tag = this;
    tag.formatted = function() {
        var ts;
        if (tag.opts.value) {
            ts = new Date(tag.opts.value);
            return strftime("%B %d, %Y %H:%M:%S", ts);
        } else {
            return null;
        }
    };
});