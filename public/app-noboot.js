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
        keepValueAttributes: false,
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
        if (!ref.parentNode) {
            return;
        }
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
        var keepValueAttributes = settings.keepValueAttributes;
        var isStyleAttr = attrName === "style";
        var isClassAttr = attrName === "class";
        var isValueAttr = attrName === "value";
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
        if (expr.attr && (!expr.wasParsedOnce || value === false || !hasValue && (!isValueAttr || isValueAttr && !keepValueAttributes))) {
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
            if (isValueAttr && dom.value !== value) {
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
                tag = mount$1(root, riotTag || root.tagName.toLowerCase(), isFunction(opts) ? opts() : opts);
                if (tag) {
                    tags.push(tag);
                }
            } else if (root.length) {
                each(root, pushTagsTo);
            }
        }
        styleManager.inject();
        if (isObject(tagName) || isFunction(tagName)) {
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
    var version = "v3.13.2";
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
        var skipAnonymous = ref.skipAnonymous;
        define(this, "isMounted", value);
        if (!isAnonymous || !skipAnonymous) {
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
            if (localStorage[query_key]) {
                value = {
                    data: localStorage.getItem(query_key)
                };
            } else {
                value = null;
            }
        }
        if (!value) {
            return missing;
        } else if (typeof value === "object" && typeof value.data !== "undefined") {
            return value.data;
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
        return value && value.data ? value.data : [];
    };
    Lockr.sismember = function(key, value, options) {
        return Lockr.smembers(key).indexOf(value) > -1;
    };
    Lockr.keys = function() {
        var keys = [];
        var allKeys = Object.keys(localStorage);
        if (Lockr.prefix.length === 0) {
            return allKeys;
        }
        allKeys.forEach(function(key) {
            if (key.indexOf(Lockr.prefix) !== -1) {
                keys.push(key.replace(Lockr.prefix, ""));
            }
        });
        return keys;
    };
    Lockr.getAll = function(includeKeys) {
        var keys = Lockr.keys();
        if (includeKeys) {
            return keys.reduce(function(accum, key) {
                var tempObj = {};
                tempObj[key] = Lockr.get(key);
                accum.push(tempObj);
                return accum;
            }, []);
        }
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
        var queryKey = this._getPrefixedKey(key);
        localStorage.removeItem(queryKey);
    };
    Lockr.flush = function() {
        if (Lockr.prefix.length) {
            Lockr.keys().forEach(function(key) {
                localStorage.removeItem(Lockr._getPrefixedKey(key));
            });
        } else {
            localStorage.clear();
        }
    };
    return Lockr;
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
    var RE_ORIGIN = /^.+?\/\/+[^/]+/, EVENT_LISTENER = "EventListener", REMOVE_EVENT_LISTENER = "remove" + EVENT_LISTENER, ADD_EVENT_LISTENER = "add" + EVENT_LISTENER, HAS_ATTRIBUTE = "hasAttribute", POPSTATE = "popstate", HASHCHANGE = "hashchange", TRIGGER = "trigger", MAX_EMIT_STACK_LEVEL = 3, win = typeof window != "undefined" && window, doc = typeof document != "undefined" && document, hist = win && history, loc = win && (hist.location || win.location), prot = Router.prototype, clickEvent = doc && doc.ontouchstart ? "touchstart" : "click", central = observable();
    var started = false, routeFound = false, debouncedEmit, current, parser, secondParser, emitStack = [], emitStackLevel = 0;
    function DEFAULT_PARSER(path) {
        return path.split(/[/?#]/);
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
        var base = route._.base;
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
        var base = route._.base;
        if (el.href !== loc.href && (el.href.split("#")[0] === loc.href.split("#")[0] || base[0] !== "#" && getPathFromRoot(el.href).indexOf(base) !== 0 || base[0] === "#" && el.href.split(base)[0] !== loc.href.split(base)[0] || !go(getPathFromBase(el.href), el.title || doc.title))) {
            return;
        }
        e.preventDefault();
    }
    function go(path, title, shouldReplace) {
        if (!hist) {
            return central[TRIGGER]("emit", getPathFromBase(path));
        }
        path = route._.base + normalize(path);
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
    route._ = {
        base: null,
        getPathFromBase: getPathFromBase
    };
    route.create = function() {
        var newSubRouter = new Router();
        var router = newSubRouter.m.bind(newSubRouter);
        router.stop = newSubRouter.s.bind(newSubRouter);
        return router;
    };
    route.base = function(arg) {
        route._.base = arg || "#";
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
                if (document.readyState === "interactive" || document.readyState === "complete") {
                    start(autoExec);
                } else {
                    document.onreadystatechange = function() {
                        if (document.readyState === "interactive") {
                            setTimeout(function() {
                                start(autoExec);
                            }, 1);
                        }
                    };
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
                        resultString += "\t";
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

!function(e, t) {
    var i = function() {
        var e = {};
        return t.apply(e, arguments), e.moxie;
    };
    "function" == typeof define && define.amd ? define("moxie", [], i) : "object" == typeof module && module.exports ? module.exports = i() : e.moxie = i();
}(this || window, function() {
    !function(e, t) {
        "use strict";
        function i(e, t) {
            for (var i, n = [], r = 0; r < e.length; ++r) {
                if (i = s[e[r]] || o(e[r]), !i) throw "module definition dependecy not found: " + e[r];
                n.push(i);
            }
            t.apply(null, n);
        }
        function n(e, n, r) {
            if ("string" != typeof e) throw "invalid module definition, module id must be defined and be a string";
            if (n === t) throw "invalid module definition, dependencies must be specified";
            if (r === t) throw "invalid module definition, definition function must be specified";
            i(n, function() {
                s[e] = r.apply(null, arguments);
            });
        }
        function r(e) {
            return !!s[e];
        }
        function o(t) {
            for (var i = e, n = t.split(/[.\/]/), r = 0; r < n.length; ++r) {
                if (!i[n[r]]) return;
                i = i[n[r]];
            }
            return i;
        }
        function a(i) {
            for (var n = 0; n < i.length; n++) {
                for (var r = e, o = i[n], a = o.split(/[.\/]/), u = 0; u < a.length - 1; ++u) r[a[u]] === t && (r[a[u]] = {}), 
                r = r[a[u]];
                r[a[a.length - 1]] = s[o];
            }
        }
        var s = {};
        n("moxie/core/utils/Basic", [], function() {
            function e(e) {
                var t;
                return e === t ? "undefined" : null === e ? "null" : e.nodeType ? "node" : {}.toString.call(e).match(/\s([a-z|A-Z]+)/)[1].toLowerCase();
            }
            function t() {
                return s(!1, !1, arguments);
            }
            function i() {
                return s(!0, !1, arguments);
            }
            function n() {
                return s(!1, !0, arguments);
            }
            function r() {
                return s(!0, !0, arguments);
            }
            function o(t) {
                switch (e(t)) {
                  case "array":
                    return s(!1, !0, [ [], t ]);

                  case "object":
                    return s(!1, !0, [ {}, t ]);

                  default:
                    return t;
                }
            }
            function a(i) {
                switch (e(i)) {
                  case "array":
                    return Array.prototype.slice.call(i);

                  case "object":
                    return t({}, i);
                }
                return i;
            }
            function s(t, i, n) {
                var r, o = n[0];
                return c(n, function(n, u) {
                    u > 0 && c(n, function(n, u) {
                        var c = -1 !== h(e(n), [ "array", "object" ]);
                        return n === r || t && o[u] === r ? !0 : (c && i && (n = a(n)), e(o[u]) === e(n) && c ? s(t, i, [ o[u], n ]) : o[u] = n, 
                        void 0);
                    });
                }), o;
            }
            function u(e, t) {
                function i() {
                    this.constructor = e;
                }
                for (var n in t) ({}).hasOwnProperty.call(t, n) && (e[n] = t[n]);
                return i.prototype = t.prototype, e.prototype = new i(), e.parent = t.prototype, 
                e;
            }
            function c(e, t) {
                var i, n, r, o;
                if (e) {
                    try {
                        i = e.length;
                    } catch (a) {
                        i = o;
                    }
                    if (i === o || "number" != typeof i) {
                        for (n in e) if (e.hasOwnProperty(n) && t(e[n], n) === !1) return;
                    } else for (r = 0; i > r; r++) if (t(e[r], r) === !1) return;
                }
            }
            function l(t) {
                var i;
                if (!t || "object" !== e(t)) return !0;
                for (i in t) return !1;
                return !0;
            }
            function d(t, i) {
                function n(r) {
                    "function" === e(t[r]) && t[r](function(e) {
                        ++r < o && !e ? n(r) : i(e);
                    });
                }
                var r = 0, o = t.length;
                "function" !== e(i) && (i = function() {}), t && t.length || i(), n(r);
            }
            function m(e, t) {
                var i = 0, n = e.length, r = new Array(n);
                c(e, function(e, o) {
                    e(function(e) {
                        if (e) return t(e);
                        var a = [].slice.call(arguments);
                        a.shift(), r[o] = a, i++, i === n && (r.unshift(null), t.apply(this, r));
                    });
                });
            }
            function h(e, t) {
                if (t) {
                    if (Array.prototype.indexOf) return Array.prototype.indexOf.call(t, e);
                    for (var i = 0, n = t.length; n > i; i++) if (t[i] === e) return i;
                }
                return -1;
            }
            function f(t, i) {
                var n = [];
                "array" !== e(t) && (t = [ t ]), "array" !== e(i) && (i = [ i ]);
                for (var r in t) -1 === h(t[r], i) && n.push(t[r]);
                return n.length ? n : !1;
            }
            function p(e, t) {
                var i = [];
                return c(e, function(e) {
                    -1 !== h(e, t) && i.push(e);
                }), i.length ? i : null;
            }
            function g(e) {
                var t, i = [];
                for (t = 0; t < e.length; t++) i[t] = e[t];
                return i;
            }
            function x(e) {
                return e ? String.prototype.trim ? String.prototype.trim.call(e) : e.toString().replace(/^\s*/, "").replace(/\s*$/, "") : e;
            }
            function v(e) {
                if ("string" != typeof e) return e;
                var t, i = {
                    t: 1099511627776,
                    g: 1073741824,
                    m: 1048576,
                    k: 1024
                };
                return e = /^([0-9\.]+)([tmgk]?)$/.exec(e.toLowerCase().replace(/[^0-9\.tmkg]/g, "")), 
                t = e[2], e = +e[1], i.hasOwnProperty(t) && (e *= i[t]), Math.floor(e);
            }
            function w(e) {
                var t = [].slice.call(arguments, 1);
                return e.replace(/%([a-z])/g, function(e, i) {
                    var n = t.shift();
                    switch (i) {
                      case "s":
                        return n + "";

                      case "d":
                        return parseInt(n, 10);

                      case "f":
                        return parseFloat(n);

                      case "c":
                        return "";

                      default:
                        return n;
                    }
                });
            }
            function y(e, t) {
                var i = this;
                setTimeout(function() {
                    e.call(i);
                }, t || 1);
            }
            var E = function() {
                var e = 0;
                return function(t) {
                    var i, n = new Date().getTime().toString(32);
                    for (i = 0; 5 > i; i++) n += Math.floor(65535 * Math.random()).toString(32);
                    return (t || "o_") + n + (e++).toString(32);
                };
            }();
            return {
                guid: E,
                typeOf: e,
                extend: t,
                extendIf: i,
                extendImmutable: n,
                extendImmutableIf: r,
                clone: o,
                inherit: u,
                each: c,
                isEmptyObj: l,
                inSeries: d,
                inParallel: m,
                inArray: h,
                arrayDiff: f,
                arrayIntersect: p,
                toArray: g,
                trim: x,
                sprintf: w,
                parseSizeStr: v,
                delay: y
            };
        }), n("moxie/core/utils/Encode", [], function() {
            var e = function(e) {
                return unescape(encodeURIComponent(e));
            }, t = function(e) {
                return decodeURIComponent(escape(e));
            }, i = function(e, i) {
                if ("function" == typeof window.atob) return i ? t(window.atob(e)) : window.atob(e);
                var n, r, o, a, s, u, c, l, d = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=", m = 0, h = 0, f = "", p = [];
                if (!e) return e;
                e += "";
                do {
                    a = d.indexOf(e.charAt(m++)), s = d.indexOf(e.charAt(m++)), u = d.indexOf(e.charAt(m++)), 
                    c = d.indexOf(e.charAt(m++)), l = a << 18 | s << 12 | u << 6 | c, n = 255 & l >> 16, 
                    r = 255 & l >> 8, o = 255 & l, p[h++] = 64 == u ? String.fromCharCode(n) : 64 == c ? String.fromCharCode(n, r) : String.fromCharCode(n, r, o);
                } while (m < e.length);
                return f = p.join(""), i ? t(f) : f;
            }, n = function(t, i) {
                if (i && (t = e(t)), "function" == typeof window.btoa) return window.btoa(t);
                var n, r, o, a, s, u, c, l, d = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=", m = 0, h = 0, f = "", p = [];
                if (!t) return t;
                do {
                    n = t.charCodeAt(m++), r = t.charCodeAt(m++), o = t.charCodeAt(m++), l = n << 16 | r << 8 | o, 
                    a = 63 & l >> 18, s = 63 & l >> 12, u = 63 & l >> 6, c = 63 & l, p[h++] = d.charAt(a) + d.charAt(s) + d.charAt(u) + d.charAt(c);
                } while (m < t.length);
                f = p.join("");
                var g = t.length % 3;
                return (g ? f.slice(0, g - 3) : f) + "===".slice(g || 3);
            };
            return {
                utf8_encode: e,
                utf8_decode: t,
                atob: i,
                btoa: n
            };
        }), n("moxie/core/utils/Env", [ "moxie/core/utils/Basic" ], function(e) {
            function i(e, t, i) {
                var n = 0, r = 0, o = 0, a = {
                    dev: -6,
                    alpha: -5,
                    a: -5,
                    beta: -4,
                    b: -4,
                    RC: -3,
                    rc: -3,
                    "#": -2,
                    p: 1,
                    pl: 1
                }, s = function(e) {
                    return e = ("" + e).replace(/[_\-+]/g, "."), e = e.replace(/([^.\d]+)/g, ".$1.").replace(/\.{2,}/g, "."), 
                    e.length ? e.split(".") : [ -8 ];
                }, u = function(e) {
                    return e ? isNaN(e) ? a[e] || -7 : parseInt(e, 10) : 0;
                };
                for (e = s(e), t = s(t), r = Math.max(e.length, t.length), n = 0; r > n; n++) if (e[n] != t[n]) {
                    if (e[n] = u(e[n]), t[n] = u(t[n]), e[n] < t[n]) {
                        o = -1;
                        break;
                    }
                    if (e[n] > t[n]) {
                        o = 1;
                        break;
                    }
                }
                if (!i) return o;
                switch (i) {
                  case ">":
                  case "gt":
                    return o > 0;

                  case ">=":
                  case "ge":
                    return o >= 0;

                  case "<=":
                  case "le":
                    return 0 >= o;

                  case "==":
                  case "=":
                  case "eq":
                    return 0 === o;

                  case "<>":
                  case "!=":
                  case "ne":
                    return 0 !== o;

                  case "":
                  case "<":
                  case "lt":
                    return 0 > o;

                  default:
                    return null;
                }
            }
            var n = function(e) {
                var t = "", i = "?", n = "function", r = "undefined", o = "object", a = "name", s = "version", u = {
                    has: function(e, t) {
                        return -1 !== t.toLowerCase().indexOf(e.toLowerCase());
                    },
                    lowerize: function(e) {
                        return e.toLowerCase();
                    }
                }, c = {
                    rgx: function() {
                        for (var t, i, a, s, u, c, l, d = 0, m = arguments; d < m.length; d += 2) {
                            var h = m[d], f = m[d + 1];
                            if (typeof t === r) {
                                t = {};
                                for (s in f) u = f[s], typeof u === o ? t[u[0]] = e : t[u] = e;
                            }
                            for (i = a = 0; i < h.length; i++) if (c = h[i].exec(this.getUA())) {
                                for (s = 0; s < f.length; s++) l = c[++a], u = f[s], typeof u === o && u.length > 0 ? 2 == u.length ? t[u[0]] = typeof u[1] == n ? u[1].call(this, l) : u[1] : 3 == u.length ? t[u[0]] = typeof u[1] !== n || u[1].exec && u[1].test ? l ? l.replace(u[1], u[2]) : e : l ? u[1].call(this, l, u[2]) : e : 4 == u.length && (t[u[0]] = l ? u[3].call(this, l.replace(u[1], u[2])) : e) : t[u] = l ? l : e;
                                break;
                            }
                            if (c) break;
                        }
                        return t;
                    },
                    str: function(t, n) {
                        for (var r in n) if (typeof n[r] === o && n[r].length > 0) {
                            for (var a = 0; a < n[r].length; a++) if (u.has(n[r][a], t)) return r === i ? e : r;
                        } else if (u.has(n[r], t)) return r === i ? e : r;
                        return t;
                    }
                }, l = {
                    browser: {
                        oldsafari: {
                            major: {
                                1: [ "/8", "/1", "/3" ],
                                2: "/4",
                                "?": "/"
                            },
                            version: {
                                "1.0": "/8",
                                1.2: "/1",
                                1.3: "/3",
                                "2.0": "/412",
                                "2.0.2": "/416",
                                "2.0.3": "/417",
                                "2.0.4": "/419",
                                "?": "/"
                            }
                        }
                    },
                    device: {
                        sprint: {
                            model: {
                                "Evo Shift 4G": "7373KT"
                            },
                            vendor: {
                                HTC: "APA",
                                Sprint: "Sprint"
                            }
                        }
                    },
                    os: {
                        windows: {
                            version: {
                                ME: "4.90",
                                "NT 3.11": "NT3.51",
                                "NT 4.0": "NT4.0",
                                2e3: "NT 5.0",
                                XP: [ "NT 5.1", "NT 5.2" ],
                                Vista: "NT 6.0",
                                7: "NT 6.1",
                                8: "NT 6.2",
                                8.1: "NT 6.3",
                                RT: "ARM"
                            }
                        }
                    }
                }, d = {
                    browser: [ [ /(opera\smini)\/([\w\.-]+)/i, /(opera\s[mobiletab]+).+version\/([\w\.-]+)/i, /(opera).+version\/([\w\.]+)/i, /(opera)[\/\s]+([\w\.]+)/i ], [ a, s ], [ /\s(opr)\/([\w\.]+)/i ], [ [ a, "Opera" ], s ], [ /(kindle)\/([\w\.]+)/i, /(lunascape|maxthon|netfront|jasmine|blazer)[\/\s]?([\w\.]+)*/i, /(avant\s|iemobile|slim|baidu)(?:browser)?[\/\s]?([\w\.]*)/i, /(?:ms|\()(ie)\s([\w\.]+)/i, /(rekonq)\/([\w\.]+)*/i, /(chromium|flock|rockmelt|midori|epiphany|silk|skyfire|ovibrowser|bolt|iron|vivaldi)\/([\w\.-]+)/i ], [ a, s ], [ /(trident).+rv[:\s]([\w\.]+).+like\sgecko/i ], [ [ a, "IE" ], s ], [ /(edge)\/((\d+)?[\w\.]+)/i ], [ a, s ], [ /(yabrowser)\/([\w\.]+)/i ], [ [ a, "Yandex" ], s ], [ /(comodo_dragon)\/([\w\.]+)/i ], [ [ a, /_/g, " " ], s ], [ /(chrome|omniweb|arora|[tizenoka]{5}\s?browser)\/v?([\w\.]+)/i, /(uc\s?browser|qqbrowser)[\/\s]?([\w\.]+)/i ], [ a, s ], [ /(dolfin)\/([\w\.]+)/i ], [ [ a, "Dolphin" ], s ], [ /((?:android.+)crmo|crios)\/([\w\.]+)/i ], [ [ a, "Chrome" ], s ], [ /XiaoMi\/MiuiBrowser\/([\w\.]+)/i ], [ s, [ a, "MIUI Browser" ] ], [ /android.+version\/([\w\.]+)\s+(?:mobile\s?safari|safari)/i ], [ s, [ a, "Android Browser" ] ], [ /FBAV\/([\w\.]+);/i ], [ s, [ a, "Facebook" ] ], [ /version\/([\w\.]+).+?mobile\/\w+\s(safari)/i ], [ s, [ a, "Mobile Safari" ] ], [ /version\/([\w\.]+).+?(mobile\s?safari|safari)/i ], [ s, a ], [ /webkit.+?(mobile\s?safari|safari)(\/[\w\.]+)/i ], [ a, [ s, c.str, l.browser.oldsafari.version ] ], [ /(konqueror)\/([\w\.]+)/i, /(webkit|khtml)\/([\w\.]+)/i ], [ a, s ], [ /(navigator|netscape)\/([\w\.-]+)/i ], [ [ a, "Netscape" ], s ], [ /(swiftfox)/i, /(icedragon|iceweasel|camino|chimera|fennec|maemo\sbrowser|minimo|conkeror)[\/\s]?([\w\.\+]+)/i, /(firefox|seamonkey|k-meleon|icecat|iceape|firebird|phoenix)\/([\w\.-]+)/i, /(mozilla)\/([\w\.]+).+rv\:.+gecko\/\d+/i, /(polaris|lynx|dillo|icab|doris|amaya|w3m|netsurf)[\/\s]?([\w\.]+)/i, /(links)\s\(([\w\.]+)/i, /(gobrowser)\/?([\w\.]+)*/i, /(ice\s?browser)\/v?([\w\._]+)/i, /(mosaic)[\/\s]([\w\.]+)/i ], [ a, s ] ],
                    engine: [ [ /windows.+\sedge\/([\w\.]+)/i ], [ s, [ a, "EdgeHTML" ] ], [ /(presto)\/([\w\.]+)/i, /(webkit|trident|netfront|netsurf|amaya|lynx|w3m)\/([\w\.]+)/i, /(khtml|tasman|links)[\/\s]\(?([\w\.]+)/i, /(icab)[\/\s]([23]\.[\d\.]+)/i ], [ a, s ], [ /rv\:([\w\.]+).*(gecko)/i ], [ s, a ] ],
                    os: [ [ /microsoft\s(windows)\s(vista|xp)/i ], [ a, s ], [ /(windows)\snt\s6\.2;\s(arm)/i, /(windows\sphone(?:\sos)*|windows\smobile|windows)[\s\/]?([ntce\d\.\s]+\w)/i ], [ a, [ s, c.str, l.os.windows.version ] ], [ /(win(?=3|9|n)|win\s9x\s)([nt\d\.]+)/i ], [ [ a, "Windows" ], [ s, c.str, l.os.windows.version ] ], [ /\((bb)(10);/i ], [ [ a, "BlackBerry" ], s ], [ /(blackberry)\w*\/?([\w\.]+)*/i, /(tizen)[\/\s]([\w\.]+)/i, /(android|webos|palm\os|qnx|bada|rim\stablet\sos|meego|contiki)[\/\s-]?([\w\.]+)*/i, /linux;.+(sailfish);/i ], [ a, s ], [ /(symbian\s?os|symbos|s60(?=;))[\/\s-]?([\w\.]+)*/i ], [ [ a, "Symbian" ], s ], [ /\((series40);/i ], [ a ], [ /mozilla.+\(mobile;.+gecko.+firefox/i ], [ [ a, "Firefox OS" ], s ], [ /(nintendo|playstation)\s([wids3portablevu]+)/i, /(mint)[\/\s\(]?(\w+)*/i, /(mageia|vectorlinux)[;\s]/i, /(joli|[kxln]?ubuntu|debian|[open]*suse|gentoo|arch|slackware|fedora|mandriva|centos|pclinuxos|redhat|zenwalk|linpus)[\/\s-]?([\w\.-]+)*/i, /(hurd|linux)\s?([\w\.]+)*/i, /(gnu)\s?([\w\.]+)*/i ], [ a, s ], [ /(cros)\s[\w]+\s([\w\.]+\w)/i ], [ [ a, "Chromium OS" ], s ], [ /(sunos)\s?([\w\.]+\d)*/i ], [ [ a, "Solaris" ], s ], [ /\s([frentopc-]{0,4}bsd|dragonfly)\s?([\w\.]+)*/i ], [ a, s ], [ /(ip[honead]+)(?:.*os\s*([\w]+)*\slike\smac|;\sopera)/i ], [ [ a, "iOS" ], [ s, /_/g, "." ] ], [ /(mac\sos\sx)\s?([\w\s\.]+\w)*/i, /(macintosh|mac(?=_powerpc)\s)/i ], [ [ a, "Mac OS" ], [ s, /_/g, "." ] ], [ /((?:open)?solaris)[\/\s-]?([\w\.]+)*/i, /(haiku)\s(\w+)/i, /(aix)\s((\d)(?=\.|\)|\s)[\w\.]*)*/i, /(plan\s9|minix|beos|os\/2|amigaos|morphos|risc\sos|openvms)/i, /(unix)\s?([\w\.]+)*/i ], [ a, s ] ]
                }, m = function(e) {
                    var i = e || (window && window.navigator && window.navigator.userAgent ? window.navigator.userAgent : t);
                    this.getBrowser = function() {
                        return c.rgx.apply(this, d.browser);
                    }, this.getEngine = function() {
                        return c.rgx.apply(this, d.engine);
                    }, this.getOS = function() {
                        return c.rgx.apply(this, d.os);
                    }, this.getResult = function() {
                        return {
                            ua: this.getUA(),
                            browser: this.getBrowser(),
                            engine: this.getEngine(),
                            os: this.getOS()
                        };
                    }, this.getUA = function() {
                        return i;
                    }, this.setUA = function(e) {
                        return i = e, this;
                    }, this.setUA(i);
                };
                return m;
            }(), r = function() {
                var i = {
                    access_global_ns: function() {
                        return !!window.moxie;
                    },
                    define_property: function() {
                        return !1;
                    }(),
                    create_canvas: function() {
                        var e = document.createElement("canvas"), t = !(!e.getContext || !e.getContext("2d"));
                        return i.create_canvas = t, t;
                    },
                    return_response_type: function(t) {
                        try {
                            if (-1 !== e.inArray(t, [ "", "text", "document" ])) return !0;
                            if (window.XMLHttpRequest) {
                                var i = new XMLHttpRequest();
                                if (i.open("get", "/"), "responseType" in i) return i.responseType = t, i.responseType !== t ? !1 : !0;
                            }
                        } catch (n) {}
                        return !1;
                    },
                    use_blob_uri: function() {
                        var e = window.URL;
                        return i.use_blob_uri = e && "createObjectURL" in e && "revokeObjectURL" in e && ("IE" !== a.browser || a.verComp(a.version, "11.0.46", ">=")), 
                        i.use_blob_uri;
                    },
                    use_data_uri: function() {
                        var e = new Image();
                        return e.onload = function() {
                            i.use_data_uri = 1 === e.width && 1 === e.height;
                        }, setTimeout(function() {
                            e.src = "data:image/gif;base64,R0lGODlhAQABAIAAAP8AAAAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==";
                        }, 1), !1;
                    }(),
                    use_data_uri_over32kb: function() {
                        return i.use_data_uri && ("IE" !== a.browser || a.version >= 9);
                    },
                    use_data_uri_of: function(e) {
                        return i.use_data_uri && 33e3 > e || i.use_data_uri_over32kb();
                    },
                    use_fileinput: function() {
                        if (navigator.userAgent.match(/(Android (1.0|1.1|1.5|1.6|2.0|2.1))|(Windows Phone (OS 7|8.0))|(XBLWP)|(ZuneWP)|(w(eb)?OSBrowser)|(webOS)|(Kindle\/(1.0|2.0|2.5|3.0))/)) return !1;
                        var e = document.createElement("input");
                        return e.setAttribute("type", "file"), i.use_fileinput = !e.disabled;
                    },
                    use_webgl: function() {
                        var e, n = document.createElement("canvas"), r = null;
                        try {
                            r = n.getContext("webgl") || n.getContext("experimental-webgl");
                        } catch (o) {}
                        return r || (r = null), e = !!r, i.use_webgl = e, n = t, e;
                    }
                };
                return function(t) {
                    var n = [].slice.call(arguments);
                    return n.shift(), "function" === e.typeOf(i[t]) ? i[t].apply(this, n) : !!i[t];
                };
            }(), o = new n().getResult(), a = {
                can: r,
                uaParser: n,
                browser: o.browser.name,
                version: o.browser.version,
                os: o.os.name,
                osVersion: o.os.version,
                verComp: i,
                swf_url: "../flash/Moxie.swf",
                xap_url: "../silverlight/Moxie.xap",
                global_event_dispatcher: "moxie.core.EventTarget.instance.dispatchEvent"
            };
            return a.OS = a.os, a;
        }), n("moxie/core/Exceptions", [ "moxie/core/utils/Basic" ], function(e) {
            function t(e, t) {
                var i;
                for (i in e) if (e[i] === t) return i;
                return null;
            }
            return {
                RuntimeError: function() {
                    function i(e, i) {
                        this.code = e, this.name = t(n, e), this.message = this.name + (i || ": RuntimeError " + this.code);
                    }
                    var n = {
                        NOT_INIT_ERR: 1,
                        EXCEPTION_ERR: 3,
                        NOT_SUPPORTED_ERR: 9,
                        JS_ERR: 4
                    };
                    return e.extend(i, n), i.prototype = Error.prototype, i;
                }(),
                OperationNotAllowedException: function() {
                    function t(e) {
                        this.code = e, this.name = "OperationNotAllowedException";
                    }
                    return e.extend(t, {
                        NOT_ALLOWED_ERR: 1
                    }), t.prototype = Error.prototype, t;
                }(),
                ImageError: function() {
                    function i(e) {
                        this.code = e, this.name = t(n, e), this.message = this.name + ": ImageError " + this.code;
                    }
                    var n = {
                        WRONG_FORMAT: 1,
                        MAX_RESOLUTION_ERR: 2,
                        INVALID_META_ERR: 3
                    };
                    return e.extend(i, n), i.prototype = Error.prototype, i;
                }(),
                FileException: function() {
                    function i(e) {
                        this.code = e, this.name = t(n, e), this.message = this.name + ": FileException " + this.code;
                    }
                    var n = {
                        NOT_FOUND_ERR: 1,
                        SECURITY_ERR: 2,
                        ABORT_ERR: 3,
                        NOT_READABLE_ERR: 4,
                        ENCODING_ERR: 5,
                        NO_MODIFICATION_ALLOWED_ERR: 6,
                        INVALID_STATE_ERR: 7,
                        SYNTAX_ERR: 8
                    };
                    return e.extend(i, n), i.prototype = Error.prototype, i;
                }(),
                DOMException: function() {
                    function i(e) {
                        this.code = e, this.name = t(n, e), this.message = this.name + ": DOMException " + this.code;
                    }
                    var n = {
                        INDEX_SIZE_ERR: 1,
                        DOMSTRING_SIZE_ERR: 2,
                        HIERARCHY_REQUEST_ERR: 3,
                        WRONG_DOCUMENT_ERR: 4,
                        INVALID_CHARACTER_ERR: 5,
                        NO_DATA_ALLOWED_ERR: 6,
                        NO_MODIFICATION_ALLOWED_ERR: 7,
                        NOT_FOUND_ERR: 8,
                        NOT_SUPPORTED_ERR: 9,
                        INUSE_ATTRIBUTE_ERR: 10,
                        INVALID_STATE_ERR: 11,
                        SYNTAX_ERR: 12,
                        INVALID_MODIFICATION_ERR: 13,
                        NAMESPACE_ERR: 14,
                        INVALID_ACCESS_ERR: 15,
                        VALIDATION_ERR: 16,
                        TYPE_MISMATCH_ERR: 17,
                        SECURITY_ERR: 18,
                        NETWORK_ERR: 19,
                        ABORT_ERR: 20,
                        URL_MISMATCH_ERR: 21,
                        QUOTA_EXCEEDED_ERR: 22,
                        TIMEOUT_ERR: 23,
                        INVALID_NODE_TYPE_ERR: 24,
                        DATA_CLONE_ERR: 25
                    };
                    return e.extend(i, n), i.prototype = Error.prototype, i;
                }(),
                EventException: function() {
                    function t(e) {
                        this.code = e, this.name = "EventException";
                    }
                    return e.extend(t, {
                        UNSPECIFIED_EVENT_TYPE_ERR: 0
                    }), t.prototype = Error.prototype, t;
                }()
            };
        }), n("moxie/core/utils/Dom", [ "moxie/core/utils/Env" ], function(e) {
            var t = function(e) {
                return "string" != typeof e ? e : document.getElementById(e);
            }, i = function(e, t) {
                if (!e.className) return !1;
                var i = new RegExp("(^|\\s+)" + t + "(\\s+|$)");
                return i.test(e.className);
            }, n = function(e, t) {
                i(e, t) || (e.className = e.className ? e.className.replace(/\s+$/, "") + " " + t : t);
            }, r = function(e, t) {
                if (e.className) {
                    var i = new RegExp("(^|\\s+)" + t + "(\\s+|$)");
                    e.className = e.className.replace(i, function(e, t, i) {
                        return " " === t && " " === i ? " " : "";
                    });
                }
            }, o = function(e, t) {
                return e.currentStyle ? e.currentStyle[t] : window.getComputedStyle ? window.getComputedStyle(e, null)[t] : void 0;
            }, a = function(t, i) {
                function n(e) {
                    var t, i, n = 0, r = 0;
                    return e && (i = e.getBoundingClientRect(), t = "CSS1Compat" === c.compatMode ? c.documentElement : c.body, 
                    n = i.left + t.scrollLeft, r = i.top + t.scrollTop), {
                        x: n,
                        y: r
                    };
                }
                var r, o, a, s = 0, u = 0, c = document;
                if (t = t, i = i || c.body, t && t.getBoundingClientRect && "IE" === e.browser && (!c.documentMode || c.documentMode < 8)) return o = n(t), 
                a = n(i), {
                    x: o.x - a.x,
                    y: o.y - a.y
                };
                for (r = t; r && r != i && r.nodeType; ) s += r.offsetLeft || 0, u += r.offsetTop || 0, 
                r = r.offsetParent;
                for (r = t.parentNode; r && r != i && r.nodeType; ) s -= r.scrollLeft || 0, u -= r.scrollTop || 0, 
                r = r.parentNode;
                return {
                    x: s,
                    y: u
                };
            }, s = function(e) {
                return {
                    w: e.offsetWidth || e.clientWidth,
                    h: e.offsetHeight || e.clientHeight
                };
            };
            return {
                get: t,
                hasClass: i,
                addClass: n,
                removeClass: r,
                getStyle: o,
                getPos: a,
                getSize: s
            };
        }), n("moxie/core/EventTarget", [ "moxie/core/utils/Env", "moxie/core/Exceptions", "moxie/core/utils/Basic" ], function(e, t, i) {
            function n() {
                this.uid = i.guid();
            }
            var r = {};
            return i.extend(n.prototype, {
                init: function() {
                    this.uid || (this.uid = i.guid("uid_"));
                },
                addEventListener: function(e, t, n, o) {
                    var a, s = this;
                    return this.hasOwnProperty("uid") || (this.uid = i.guid("uid_")), e = i.trim(e), 
                    /\s/.test(e) ? (i.each(e.split(/\s+/), function(e) {
                        s.addEventListener(e, t, n, o);
                    }), void 0) : (e = e.toLowerCase(), n = parseInt(n, 10) || 0, a = r[this.uid] && r[this.uid][e] || [], 
                    a.push({
                        fn: t,
                        priority: n,
                        scope: o || this
                    }), r[this.uid] || (r[this.uid] = {}), r[this.uid][e] = a, void 0);
                },
                hasEventListener: function(e) {
                    var t;
                    return e ? (e = e.toLowerCase(), t = r[this.uid] && r[this.uid][e]) : t = r[this.uid], 
                    t ? t : !1;
                },
                removeEventListener: function(e, t) {
                    var n, o, a = this;
                    if (e = e.toLowerCase(), /\s/.test(e)) return i.each(e.split(/\s+/), function(e) {
                        a.removeEventListener(e, t);
                    }), void 0;
                    if (n = r[this.uid] && r[this.uid][e]) {
                        if (t) {
                            for (o = n.length - 1; o >= 0; o--) if (n[o].fn === t) {
                                n.splice(o, 1);
                                break;
                            }
                        } else n = [];
                        n.length || (delete r[this.uid][e], i.isEmptyObj(r[this.uid]) && delete r[this.uid]);
                    }
                },
                removeAllEventListeners: function() {
                    r[this.uid] && delete r[this.uid];
                },
                dispatchEvent: function(e) {
                    var n, o, a, s, u, c = {}, l = !0;
                    if ("string" !== i.typeOf(e)) {
                        if (s = e, "string" !== i.typeOf(s.type)) throw new t.EventException(t.EventException.UNSPECIFIED_EVENT_TYPE_ERR);
                        e = s.type, s.total !== u && s.loaded !== u && (c.total = s.total, c.loaded = s.loaded), 
                        c.async = s.async || !1;
                    }
                    if (-1 !== e.indexOf("::") ? function(t) {
                        n = t[0], e = t[1];
                    }(e.split("::")) : n = this.uid, e = e.toLowerCase(), o = r[n] && r[n][e]) {
                        o.sort(function(e, t) {
                            return t.priority - e.priority;
                        }), a = [].slice.call(arguments), a.shift(), c.type = e, a.unshift(c);
                        var d = [];
                        i.each(o, function(e) {
                            a[0].target = e.scope, c.async ? d.push(function(t) {
                                setTimeout(function() {
                                    t(e.fn.apply(e.scope, a) === !1);
                                }, 1);
                            }) : d.push(function(t) {
                                t(e.fn.apply(e.scope, a) === !1);
                            });
                        }), d.length && i.inSeries(d, function(e) {
                            l = !e;
                        });
                    }
                    return l;
                },
                bindOnce: function(e, t, i, n) {
                    var r = this;
                    r.bind.call(this, e, function o() {
                        return r.unbind(e, o), t.apply(this, arguments);
                    }, i, n);
                },
                bind: function() {
                    this.addEventListener.apply(this, arguments);
                },
                unbind: function() {
                    this.removeEventListener.apply(this, arguments);
                },
                unbindAll: function() {
                    this.removeAllEventListeners.apply(this, arguments);
                },
                trigger: function() {
                    return this.dispatchEvent.apply(this, arguments);
                },
                handleEventProps: function(e) {
                    var t = this;
                    this.bind(e.join(" "), function(e) {
                        var t = "on" + e.type.toLowerCase();
                        "function" === i.typeOf(this[t]) && this[t].apply(this, arguments);
                    }), i.each(e, function(e) {
                        e = "on" + e.toLowerCase(e), "undefined" === i.typeOf(t[e]) && (t[e] = null);
                    });
                }
            }), n.instance = new n(), n;
        }), n("moxie/runtime/Runtime", [ "moxie/core/utils/Env", "moxie/core/utils/Basic", "moxie/core/utils/Dom", "moxie/core/EventTarget" ], function(e, t, i, n) {
            function r(e, n, o, s, u) {
                var c, l = this, d = t.guid(n + "_"), m = u || "browser";
                e = e || {}, a[d] = this, o = t.extend({
                    access_binary: !1,
                    access_image_binary: !1,
                    display_media: !1,
                    do_cors: !1,
                    drag_and_drop: !1,
                    filter_by_extension: !0,
                    resize_image: !1,
                    report_upload_progress: !1,
                    return_response_headers: !1,
                    return_response_type: !1,
                    return_status_code: !0,
                    send_custom_headers: !1,
                    select_file: !1,
                    select_folder: !1,
                    select_multiple: !0,
                    send_binary_string: !1,
                    send_browser_cookies: !0,
                    send_multipart: !0,
                    slice_blob: !1,
                    stream_upload: !1,
                    summon_file_dialog: !1,
                    upload_filesize: !0,
                    use_http_method: !0
                }, o), e.preferred_caps && (m = r.getMode(s, e.preferred_caps, m)), c = function() {
                    var e = {};
                    return {
                        exec: function(t, i, n, r) {
                            return c[i] && (e[t] || (e[t] = {
                                context: this,
                                instance: new c[i]()
                            }), e[t].instance[n]) ? e[t].instance[n].apply(this, r) : void 0;
                        },
                        removeInstance: function(t) {
                            delete e[t];
                        },
                        removeAllInstances: function() {
                            var i = this;
                            t.each(e, function(e, n) {
                                "function" === t.typeOf(e.instance.destroy) && e.instance.destroy.call(e.context), 
                                i.removeInstance(n);
                            });
                        }
                    };
                }(), t.extend(this, {
                    initialized: !1,
                    uid: d,
                    type: n,
                    mode: r.getMode(s, e.required_caps, m),
                    shimid: d + "_container",
                    clients: 0,
                    options: e,
                    can: function(e, i) {
                        var n = arguments[2] || o;
                        if ("string" === t.typeOf(e) && "undefined" === t.typeOf(i) && (e = r.parseCaps(e)), 
                        "object" === t.typeOf(e)) {
                            for (var a in e) if (!this.can(a, e[a], n)) return !1;
                            return !0;
                        }
                        return "function" === t.typeOf(n[e]) ? n[e].call(this, i) : i === n[e];
                    },
                    getShimContainer: function() {
                        var e, n = i.get(this.shimid);
                        return n || (e = i.get(this.options.container) || document.body, n = document.createElement("div"), 
                        n.id = this.shimid, n.className = "moxie-shim moxie-shim-" + this.type, t.extend(n.style, {
                            position: "absolute",
                            top: "0px",
                            left: "0px",
                            width: "1px",
                            height: "1px",
                            overflow: "hidden"
                        }), e.appendChild(n), e = null), n;
                    },
                    getShim: function() {
                        return c;
                    },
                    shimExec: function(e, t) {
                        var i = [].slice.call(arguments, 2);
                        return l.getShim().exec.call(this, this.uid, e, t, i);
                    },
                    exec: function(e, t) {
                        var i = [].slice.call(arguments, 2);
                        return l[e] && l[e][t] ? l[e][t].apply(this, i) : l.shimExec.apply(this, arguments);
                    },
                    destroy: function() {
                        if (l) {
                            var e = i.get(this.shimid);
                            e && e.parentNode.removeChild(e), c && c.removeAllInstances(), this.unbindAll(), 
                            delete a[this.uid], this.uid = null, d = l = c = e = null;
                        }
                    }
                }), this.mode && e.required_caps && !this.can(e.required_caps) && (this.mode = !1);
            }
            var o = {}, a = {};
            return r.order = "html5,flash,silverlight,html4", r.getRuntime = function(e) {
                return a[e] ? a[e] : !1;
            }, r.addConstructor = function(e, t) {
                t.prototype = n.instance, o[e] = t;
            }, r.getConstructor = function(e) {
                return o[e] || null;
            }, r.getInfo = function(e) {
                var t = r.getRuntime(e);
                return t ? {
                    uid: t.uid,
                    type: t.type,
                    mode: t.mode,
                    can: function() {
                        return t.can.apply(t, arguments);
                    }
                } : null;
            }, r.parseCaps = function(e) {
                var i = {};
                return "string" !== t.typeOf(e) ? e || {} : (t.each(e.split(","), function(e) {
                    i[e] = !0;
                }), i);
            }, r.can = function(e, t) {
                var i, n, o = r.getConstructor(e);
                return o ? (i = new o({
                    required_caps: t
                }), n = i.mode, i.destroy(), !!n) : !1;
            }, r.thatCan = function(e, t) {
                var i = (t || r.order).split(/\s*,\s*/);
                for (var n in i) if (r.can(i[n], e)) return i[n];
                return null;
            }, r.getMode = function(e, i, n) {
                var r = null;
                if ("undefined" === t.typeOf(n) && (n = "browser"), i && !t.isEmptyObj(e)) {
                    if (t.each(i, function(i, n) {
                        if (e.hasOwnProperty(n)) {
                            var o = e[n](i);
                            if ("string" == typeof o && (o = [ o ]), r) {
                                if (!(r = t.arrayIntersect(r, o))) return r = !1;
                            } else r = o;
                        }
                    }), r) return -1 !== t.inArray(n, r) ? n : r[0];
                    if (r === !1) return !1;
                }
                return n;
            }, r.getGlobalEventTarget = function() {
                if (/^moxie\./.test(e.global_event_dispatcher) && !e.can("access_global_ns")) {
                    var i = t.guid("moxie_event_target_");
                    window[i] = function(e, t) {
                        n.instance.dispatchEvent(e, t);
                    }, e.global_event_dispatcher = i;
                }
                return e.global_event_dispatcher;
            }, r.capTrue = function() {
                return !0;
            }, r.capFalse = function() {
                return !1;
            }, r.capTest = function(e) {
                return function() {
                    return !!e;
                };
            }, r;
        }), n("moxie/runtime/RuntimeClient", [ "moxie/core/utils/Env", "moxie/core/Exceptions", "moxie/core/utils/Basic", "moxie/runtime/Runtime" ], function(e, t, i, n) {
            return function() {
                var e;
                i.extend(this, {
                    connectRuntime: function(r) {
                        function o(i) {
                            var a, u;
                            return i.length ? (a = i.shift().toLowerCase(), (u = n.getConstructor(a)) ? (e = new u(r), 
                            e.bind("Init", function() {
                                e.initialized = !0, setTimeout(function() {
                                    e.clients++, s.ruid = e.uid, s.trigger("RuntimeInit", e);
                                }, 1);
                            }), e.bind("Error", function() {
                                e.destroy(), o(i);
                            }), e.bind("Exception", function(e, i) {
                                var n = i.name + "(#" + i.code + ")" + (i.message ? ", from: " + i.message : "");
                                s.trigger("RuntimeError", new t.RuntimeError(t.RuntimeError.EXCEPTION_ERR, n));
                            }), e.mode ? (e.init(), void 0) : (e.trigger("Error"), void 0)) : (o(i), void 0)) : (s.trigger("RuntimeError", new t.RuntimeError(t.RuntimeError.NOT_INIT_ERR)), 
                            e = null, void 0);
                        }
                        var a, s = this;
                        if ("string" === i.typeOf(r) ? a = r : "string" === i.typeOf(r.ruid) && (a = r.ruid), 
                        a) {
                            if (e = n.getRuntime(a)) return s.ruid = a, e.clients++, e;
                            throw new t.RuntimeError(t.RuntimeError.NOT_INIT_ERR);
                        }
                        o((r.runtime_order || n.order).split(/\s*,\s*/));
                    },
                    disconnectRuntime: function() {
                        e && --e.clients <= 0 && e.destroy(), e = null;
                    },
                    getRuntime: function() {
                        return e && e.uid ? e : e = null;
                    },
                    exec: function() {
                        return e ? e.exec.apply(this, arguments) : null;
                    },
                    can: function(t) {
                        return e ? e.can(t) : !1;
                    }
                });
            };
        }), n("moxie/file/Blob", [ "moxie/core/utils/Basic", "moxie/core/utils/Encode", "moxie/runtime/RuntimeClient" ], function(e, t, i) {
            function n(o, a) {
                function s(t, i, o) {
                    var a, s = r[this.uid];
                    return "string" === e.typeOf(s) && s.length ? (a = new n(null, {
                        type: o,
                        size: i - t
                    }), a.detach(s.substr(t, a.size)), a) : null;
                }
                i.call(this), o && this.connectRuntime(o), a ? "string" === e.typeOf(a) && (a = {
                    data: a
                }) : a = {}, e.extend(this, {
                    uid: a.uid || e.guid("uid_"),
                    ruid: o,
                    size: a.size || 0,
                    type: a.type || "",
                    slice: function(e, t, i) {
                        return this.isDetached() ? s.apply(this, arguments) : this.getRuntime().exec.call(this, "Blob", "slice", this.getSource(), e, t, i);
                    },
                    getSource: function() {
                        return r[this.uid] ? r[this.uid] : null;
                    },
                    detach: function(e) {
                        if (this.ruid && (this.getRuntime().exec.call(this, "Blob", "destroy"), this.disconnectRuntime(), 
                        this.ruid = null), e = e || "", "data:" == e.substr(0, 5)) {
                            var i = e.indexOf(";base64,");
                            this.type = e.substring(5, i), e = t.atob(e.substring(i + 8));
                        }
                        this.size = e.length, r[this.uid] = e;
                    },
                    isDetached: function() {
                        return !this.ruid && "string" === e.typeOf(r[this.uid]);
                    },
                    destroy: function() {
                        this.detach(), delete r[this.uid];
                    }
                }), a.data ? this.detach(a.data) : r[this.uid] = a;
            }
            var r = {};
            return n;
        }), n("moxie/core/I18n", [ "moxie/core/utils/Basic" ], function(e) {
            var t = {};
            return {
                addI18n: function(i) {
                    return e.extend(t, i);
                },
                translate: function(e) {
                    return t[e] || e;
                },
                _: function(e) {
                    return this.translate(e);
                },
                sprintf: function(t) {
                    var i = [].slice.call(arguments, 1);
                    return t.replace(/%[a-z]/g, function() {
                        var t = i.shift();
                        return "undefined" !== e.typeOf(t) ? t : "";
                    });
                }
            };
        }), n("moxie/core/utils/Mime", [ "moxie/core/utils/Basic", "moxie/core/I18n" ], function(e, t) {
            var i = "application/msword,doc dot,application/pdf,pdf,application/pgp-signature,pgp,application/postscript,ps ai eps,application/rtf,rtf,application/vnd.ms-excel,xls xlb xlt xla,application/vnd.ms-powerpoint,ppt pps pot ppa,application/zip,zip,application/x-shockwave-flash,swf swfl,application/vnd.openxmlformats-officedocument.wordprocessingml.document,docx,application/vnd.openxmlformats-officedocument.wordprocessingml.template,dotx,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,xlsx,application/vnd.openxmlformats-officedocument.presentationml.presentation,pptx,application/vnd.openxmlformats-officedocument.presentationml.template,potx,application/vnd.openxmlformats-officedocument.presentationml.slideshow,ppsx,application/x-javascript,js,application/json,json,audio/mpeg,mp3 mpga mpega mp2,audio/x-wav,wav,audio/x-m4a,m4a,audio/ogg,oga ogg,audio/aiff,aiff aif,audio/flac,flac,audio/aac,aac,audio/ac3,ac3,audio/x-ms-wma,wma,image/bmp,bmp,image/gif,gif,image/jpeg,jpg jpeg jpe,image/photoshop,psd,image/png,png,image/svg+xml,svg svgz,image/tiff,tiff tif,text/plain,asc txt text diff log,text/html,htm html xhtml,text/css,css,text/csv,csv,text/rtf,rtf,video/mpeg,mpeg mpg mpe m2v,video/quicktime,qt mov,video/mp4,mp4,video/x-m4v,m4v,video/x-flv,flv,video/x-ms-wmv,wmv,video/avi,avi,video/webm,webm,video/3gpp,3gpp 3gp,video/3gpp2,3g2,video/vnd.rn-realvideo,rv,video/ogg,ogv,video/x-matroska,mkv,application/vnd.oasis.opendocument.formula-template,otf,application/octet-stream,exe", n = {}, r = {}, o = function(e) {
                var t, i, o, a = e.split(/,/);
                for (t = 0; t < a.length; t += 2) {
                    for (o = a[t + 1].split(/ /), i = 0; i < o.length; i++) n[o[i]] = a[t];
                    r[a[t]] = o;
                }
            }, a = function(t, i) {
                var n, r, o, a, s = [];
                for (r = 0; r < t.length; r++) for (n = t[r].extensions.toLowerCase().split(/\s*,\s*/), 
                o = 0; o < n.length; o++) {
                    if ("*" === n[o]) return [];
                    if (a = s[n[o]], i && /^\w+$/.test(n[o])) s.push("." + n[o]); else if (a && -1 === e.inArray(a, s)) s.push(a); else if (!a) return [];
                }
                return s;
            }, s = function(t) {
                var i = [];
                return e.each(t, function(t) {
                    if (t = t.toLowerCase(), "*" === t) return i = [], !1;
                    var n = t.match(/^(\w+)\/(\*|\w+)$/);
                    n && ("*" === n[2] ? e.each(r, function(e, t) {
                        new RegExp("^" + n[1] + "/").test(t) && [].push.apply(i, r[t]);
                    }) : r[t] && [].push.apply(i, r[t]));
                }), i;
            }, u = function(i) {
                var n = [], r = [];
                return "string" === e.typeOf(i) && (i = e.trim(i).split(/\s*,\s*/)), r = s(i), n.push({
                    title: t.translate("Files"),
                    extensions: r.length ? r.join(",") : "*"
                }), n;
            }, c = function(e) {
                var t = e && e.match(/\.([^.]+)$/);
                return t ? t[1].toLowerCase() : "";
            }, l = function(e) {
                return n[c(e)] || "";
            };
            return o(i), {
                mimes: n,
                extensions: r,
                addMimeType: o,
                extList2mimes: a,
                mimes2exts: s,
                mimes2extList: u,
                getFileExtension: c,
                getFileMime: l
            };
        }), n("moxie/file/FileInput", [ "moxie/core/utils/Basic", "moxie/core/utils/Env", "moxie/core/utils/Mime", "moxie/core/utils/Dom", "moxie/core/Exceptions", "moxie/core/EventTarget", "moxie/core/I18n", "moxie/runtime/Runtime", "moxie/runtime/RuntimeClient" ], function(e, t, i, n, r, o, a, s, u) {
            function c(t) {
                var o, c, d;
                if (-1 !== e.inArray(e.typeOf(t), [ "string", "node" ]) && (t = {
                    browse_button: t
                }), c = n.get(t.browse_button), !c) throw new r.DOMException(r.DOMException.NOT_FOUND_ERR);
                d = {
                    accept: [ {
                        title: a.translate("All Files"),
                        extensions: "*"
                    } ],
                    multiple: !1,
                    required_caps: !1,
                    container: c.parentNode || document.body
                }, t = e.extend({}, d, t), "string" == typeof t.required_caps && (t.required_caps = s.parseCaps(t.required_caps)), 
                "string" == typeof t.accept && (t.accept = i.mimes2extList(t.accept)), o = n.get(t.container), 
                o || (o = document.body), "static" === n.getStyle(o, "position") && (o.style.position = "relative"), 
                o = c = null, u.call(this), e.extend(this, {
                    uid: e.guid("uid_"),
                    ruid: null,
                    shimid: null,
                    files: null,
                    init: function() {
                        var i = this;
                        i.bind("RuntimeInit", function(r, o) {
                            i.ruid = o.uid, i.shimid = o.shimid, i.bind("Ready", function() {
                                i.trigger("Refresh");
                            }, 999), i.bind("Refresh", function() {
                                var i, r, a, s, u;
                                a = n.get(t.browse_button), s = n.get(o.shimid), a && (i = n.getPos(a, n.get(t.container)), 
                                r = n.getSize(a), u = parseInt(n.getStyle(a, "z-index"), 10) || 0, s && e.extend(s.style, {
                                    top: i.y + "px",
                                    left: i.x + "px",
                                    width: r.w + "px",
                                    height: r.h + "px",
                                    zIndex: u + 1
                                })), s = a = null;
                            }), o.exec.call(i, "FileInput", "init", t);
                        }), i.connectRuntime(e.extend({}, t, {
                            required_caps: {
                                select_file: !0
                            }
                        }));
                    },
                    getOption: function(e) {
                        return t[e];
                    },
                    setOption: function(e, n) {
                        if (t.hasOwnProperty(e)) {
                            var o = t[e];
                            switch (e) {
                              case "accept":
                                "string" == typeof n && (n = i.mimes2extList(n));
                                break;

                              case "container":
                              case "required_caps":
                                throw new r.FileException(r.FileException.NO_MODIFICATION_ALLOWED_ERR);
                            }
                            t[e] = n, this.exec("FileInput", "setOption", e, n), this.trigger("OptionChanged", e, n, o);
                        }
                    },
                    disable: function(t) {
                        var i = this.getRuntime();
                        i && this.exec("FileInput", "disable", "undefined" === e.typeOf(t) ? !0 : t);
                    },
                    refresh: function() {
                        this.trigger("Refresh");
                    },
                    destroy: function() {
                        var t = this.getRuntime();
                        t && (t.exec.call(this, "FileInput", "destroy"), this.disconnectRuntime()), "array" === e.typeOf(this.files) && e.each(this.files, function(e) {
                            e.destroy();
                        }), this.files = null, this.unbindAll();
                    }
                }), this.handleEventProps(l);
            }
            var l = [ "ready", "change", "cancel", "mouseenter", "mouseleave", "mousedown", "mouseup" ];
            return c.prototype = o.instance, c;
        }), n("moxie/file/File", [ "moxie/core/utils/Basic", "moxie/core/utils/Mime", "moxie/file/Blob" ], function(e, t, i) {
            function n(n, r) {
                r || (r = {}), i.apply(this, arguments), this.type || (this.type = t.getFileMime(r.name));
                var o;
                if (r.name) o = r.name.replace(/\\/g, "/"), o = o.substr(o.lastIndexOf("/") + 1); else if (this.type) {
                    var a = this.type.split("/")[0];
                    o = e.guid(("" !== a ? a : "file") + "_"), t.extensions[this.type] && (o += "." + t.extensions[this.type][0]);
                }
                e.extend(this, {
                    name: o || e.guid("file_"),
                    relativePath: "",
                    lastModifiedDate: r.lastModifiedDate || new Date().toLocaleString()
                });
            }
            return n.prototype = i.prototype, n;
        }), n("moxie/file/FileDrop", [ "moxie/core/I18n", "moxie/core/utils/Dom", "moxie/core/Exceptions", "moxie/core/utils/Basic", "moxie/core/utils/Env", "moxie/file/File", "moxie/runtime/RuntimeClient", "moxie/core/EventTarget", "moxie/core/utils/Mime" ], function(e, t, i, n, r, o, a, s, u) {
            function c(i) {
                var r, o = this;
                "string" == typeof i && (i = {
                    drop_zone: i
                }), r = {
                    accept: [ {
                        title: e.translate("All Files"),
                        extensions: "*"
                    } ],
                    required_caps: {
                        drag_and_drop: !0
                    }
                }, i = "object" == typeof i ? n.extend({}, r, i) : r, i.container = t.get(i.drop_zone) || document.body, 
                "static" === t.getStyle(i.container, "position") && (i.container.style.position = "relative"), 
                "string" == typeof i.accept && (i.accept = u.mimes2extList(i.accept)), a.call(o), 
                n.extend(o, {
                    uid: n.guid("uid_"),
                    ruid: null,
                    files: null,
                    init: function() {
                        o.bind("RuntimeInit", function(e, t) {
                            o.ruid = t.uid, t.exec.call(o, "FileDrop", "init", i), o.dispatchEvent("ready");
                        }), o.connectRuntime(i);
                    },
                    destroy: function() {
                        var e = this.getRuntime();
                        e && (e.exec.call(this, "FileDrop", "destroy"), this.disconnectRuntime()), this.files = null, 
                        this.unbindAll();
                    }
                }), this.handleEventProps(l);
            }
            var l = [ "ready", "dragenter", "dragleave", "drop", "error" ];
            return c.prototype = s.instance, c;
        }), n("moxie/file/FileReader", [ "moxie/core/utils/Basic", "moxie/core/utils/Encode", "moxie/core/Exceptions", "moxie/core/EventTarget", "moxie/file/Blob", "moxie/runtime/RuntimeClient" ], function(e, t, i, n, r, o) {
            function a() {
                function n(e, n) {
                    if (this.trigger("loadstart"), this.readyState === a.LOADING) return this.trigger("error", new i.DOMException(i.DOMException.INVALID_STATE_ERR)), 
                    this.trigger("loadend"), void 0;
                    if (!(n instanceof r)) return this.trigger("error", new i.DOMException(i.DOMException.NOT_FOUND_ERR)), 
                    this.trigger("loadend"), void 0;
                    if (this.result = null, this.readyState = a.LOADING, n.isDetached()) {
                        var o = n.getSource();
                        switch (e) {
                          case "readAsText":
                          case "readAsBinaryString":
                            this.result = o;
                            break;

                          case "readAsDataURL":
                            this.result = "data:" + n.type + ";base64," + t.btoa(o);
                        }
                        this.readyState = a.DONE, this.trigger("load"), this.trigger("loadend");
                    } else this.connectRuntime(n.ruid), this.exec("FileReader", "read", e, n);
                }
                o.call(this), e.extend(this, {
                    uid: e.guid("uid_"),
                    readyState: a.EMPTY,
                    result: null,
                    error: null,
                    readAsBinaryString: function(e) {
                        n.call(this, "readAsBinaryString", e);
                    },
                    readAsDataURL: function(e) {
                        n.call(this, "readAsDataURL", e);
                    },
                    readAsText: function(e) {
                        n.call(this, "readAsText", e);
                    },
                    abort: function() {
                        this.result = null, -1 === e.inArray(this.readyState, [ a.EMPTY, a.DONE ]) && (this.readyState === a.LOADING && (this.readyState = a.DONE), 
                        this.exec("FileReader", "abort"), this.trigger("abort"), this.trigger("loadend"));
                    },
                    destroy: function() {
                        this.abort(), this.exec("FileReader", "destroy"), this.disconnectRuntime(), this.unbindAll();
                    }
                }), this.handleEventProps(s), this.bind("Error", function(e, t) {
                    this.readyState = a.DONE, this.error = t;
                }, 999), this.bind("Load", function() {
                    this.readyState = a.DONE;
                }, 999);
            }
            var s = [ "loadstart", "progress", "load", "abort", "error", "loadend" ];
            return a.EMPTY = 0, a.LOADING = 1, a.DONE = 2, a.prototype = n.instance, a;
        }), n("moxie/core/utils/Url", [ "moxie/core/utils/Basic" ], function(e) {
            var t = function(i, n) {
                var r, o = [ "source", "scheme", "authority", "userInfo", "user", "pass", "host", "port", "relative", "path", "directory", "file", "query", "fragment" ], a = o.length, s = {
                    http: 80,
                    https: 443
                }, u = {}, c = /^(?:([^:\/?#]+):)?(?:\/\/()(?:(?:()(?:([^:@\/]*):?([^:@\/]*))?@)?(\[[\da-fA-F:]+\]|[^:\/?#]*)(?::(\d*))?))?()(?:(()(?:(?:[^?#\/]*\/)*)()(?:[^?#]*))(?:\\?([^#]*))?(?:#(.*))?)/, l = c.exec(i || ""), d = /^\/\/\w/.test(i);
                switch (e.typeOf(n)) {
                  case "undefined":
                    n = t(document.location.href, !1);
                    break;

                  case "string":
                    n = t(n, !1);
                }
                for (;a--; ) l[a] && (u[o[a]] = l[a]);
                if (r = !d && !u.scheme, (d || r) && (u.scheme = n.scheme), r) {
                    u.host = n.host, u.port = n.port;
                    var m = "";
                    /^[^\/]/.test(u.path) && (m = n.path, m = /\/[^\/]*\.[^\/]*$/.test(m) ? m.replace(/\/[^\/]+$/, "/") : m.replace(/\/?$/, "/")), 
                    u.path = m + (u.path || "");
                }
                return u.port || (u.port = s[u.scheme] || 80), u.port = parseInt(u.port, 10), u.path || (u.path = "/"), 
                delete u.source, u;
            }, i = function(e) {
                var i = {
                    http: 80,
                    https: 443
                }, n = "object" == typeof e ? e : t(e);
                return n.scheme + "://" + n.host + (n.port !== i[n.scheme] ? ":" + n.port : "") + n.path + (n.query ? n.query : "");
            }, n = function(e) {
                function i(e) {
                    return [ e.scheme, e.host, e.port ].join("/");
                }
                return "string" == typeof e && (e = t(e)), i(t()) === i(e);
            };
            return {
                parseUrl: t,
                resolveUrl: i,
                hasSameOrigin: n
            };
        }), n("moxie/runtime/RuntimeTarget", [ "moxie/core/utils/Basic", "moxie/runtime/RuntimeClient", "moxie/core/EventTarget" ], function(e, t, i) {
            function n() {
                this.uid = e.guid("uid_"), t.call(this), this.destroy = function() {
                    this.disconnectRuntime(), this.unbindAll();
                };
            }
            return n.prototype = i.instance, n;
        }), n("moxie/file/FileReaderSync", [ "moxie/core/utils/Basic", "moxie/runtime/RuntimeClient", "moxie/core/utils/Encode" ], function(e, t, i) {
            return function() {
                function n(e, t) {
                    if (!t.isDetached()) {
                        var n = this.connectRuntime(t.ruid).exec.call(this, "FileReaderSync", "read", e, t);
                        return this.disconnectRuntime(), n;
                    }
                    var r = t.getSource();
                    switch (e) {
                      case "readAsBinaryString":
                        return r;

                      case "readAsDataURL":
                        return "data:" + t.type + ";base64," + i.btoa(r);

                      case "readAsText":
                        for (var o = "", a = 0, s = r.length; s > a; a++) o += String.fromCharCode(r[a]);
                        return o;
                    }
                }
                t.call(this), e.extend(this, {
                    uid: e.guid("uid_"),
                    readAsBinaryString: function(e) {
                        return n.call(this, "readAsBinaryString", e);
                    },
                    readAsDataURL: function(e) {
                        return n.call(this, "readAsDataURL", e);
                    },
                    readAsText: function(e) {
                        return n.call(this, "readAsText", e);
                    }
                });
            };
        }), n("moxie/xhr/FormData", [ "moxie/core/Exceptions", "moxie/core/utils/Basic", "moxie/file/Blob" ], function(e, t, i) {
            function n() {
                var e, n = [];
                t.extend(this, {
                    append: function(r, o) {
                        var a = this, s = t.typeOf(o);
                        o instanceof i ? e = {
                            name: r,
                            value: o
                        } : "array" === s ? (r += "[]", t.each(o, function(e) {
                            a.append(r, e);
                        })) : "object" === s ? t.each(o, function(e, t) {
                            a.append(r + "[" + t + "]", e);
                        }) : "null" === s || "undefined" === s || "number" === s && isNaN(o) ? a.append(r, "false") : n.push({
                            name: r,
                            value: o.toString()
                        });
                    },
                    hasBlob: function() {
                        return !!this.getBlob();
                    },
                    getBlob: function() {
                        return e && e.value || null;
                    },
                    getBlobName: function() {
                        return e && e.name || null;
                    },
                    each: function(i) {
                        t.each(n, function(e) {
                            i(e.value, e.name);
                        }), e && i(e.value, e.name);
                    },
                    destroy: function() {
                        e = null, n = [];
                    }
                });
            }
            return n;
        }), n("moxie/xhr/XMLHttpRequest", [ "moxie/core/utils/Basic", "moxie/core/Exceptions", "moxie/core/EventTarget", "moxie/core/utils/Encode", "moxie/core/utils/Url", "moxie/runtime/Runtime", "moxie/runtime/RuntimeTarget", "moxie/file/Blob", "moxie/file/FileReaderSync", "moxie/xhr/FormData", "moxie/core/utils/Env", "moxie/core/utils/Mime" ], function(e, t, i, n, r, o, a, s, u, c, l, d) {
            function m() {
                this.uid = e.guid("uid_");
            }
            function h() {
                function i(e, t) {
                    return I.hasOwnProperty(e) ? 1 === arguments.length ? l.can("define_property") ? I[e] : A[e] : (l.can("define_property") ? I[e] = t : A[e] = t, 
                    void 0) : void 0;
                }
                function u(t) {
                    function n() {
                        _ && (_.destroy(), _ = null), s.dispatchEvent("loadend"), s = null;
                    }
                    function r(r) {
                        _.bind("LoadStart", function(e) {
                            i("readyState", h.LOADING), s.dispatchEvent("readystatechange"), s.dispatchEvent(e), 
                            L && s.upload.dispatchEvent(e);
                        }), _.bind("Progress", function(e) {
                            i("readyState") !== h.LOADING && (i("readyState", h.LOADING), s.dispatchEvent("readystatechange")), 
                            s.dispatchEvent(e);
                        }), _.bind("UploadProgress", function(e) {
                            L && s.upload.dispatchEvent({
                                type: "progress",
                                lengthComputable: !1,
                                total: e.total,
                                loaded: e.loaded
                            });
                        }), _.bind("Load", function(t) {
                            i("readyState", h.DONE), i("status", Number(r.exec.call(_, "XMLHttpRequest", "getStatus") || 0)), 
                            i("statusText", f[i("status")] || ""), i("response", r.exec.call(_, "XMLHttpRequest", "getResponse", i("responseType"))), 
                            ~e.inArray(i("responseType"), [ "text", "" ]) ? i("responseText", i("response")) : "document" === i("responseType") && i("responseXML", i("response")), 
                            U = r.exec.call(_, "XMLHttpRequest", "getAllResponseHeaders"), s.dispatchEvent("readystatechange"), 
                            i("status") > 0 ? (L && s.upload.dispatchEvent(t), s.dispatchEvent(t)) : (F = !0, 
                            s.dispatchEvent("error")), n();
                        }), _.bind("Abort", function(e) {
                            s.dispatchEvent(e), n();
                        }), _.bind("Error", function(e) {
                            F = !0, i("readyState", h.DONE), s.dispatchEvent("readystatechange"), M = !0, s.dispatchEvent(e), 
                            n();
                        }), r.exec.call(_, "XMLHttpRequest", "send", {
                            url: x,
                            method: v,
                            async: T,
                            user: w,
                            password: y,
                            headers: S,
                            mimeType: D,
                            encoding: O,
                            responseType: s.responseType,
                            withCredentials: s.withCredentials,
                            options: k
                        }, t);
                    }
                    var s = this;
                    E = new Date().getTime(), _ = new a(), "string" == typeof k.required_caps && (k.required_caps = o.parseCaps(k.required_caps)), 
                    k.required_caps = e.extend({}, k.required_caps, {
                        return_response_type: s.responseType
                    }), t instanceof c && (k.required_caps.send_multipart = !0), e.isEmptyObj(S) || (k.required_caps.send_custom_headers = !0), 
                    B || (k.required_caps.do_cors = !0), k.ruid ? r(_.connectRuntime(k)) : (_.bind("RuntimeInit", function(e, t) {
                        r(t);
                    }), _.bind("RuntimeError", function(e, t) {
                        s.dispatchEvent("RuntimeError", t);
                    }), _.connectRuntime(k));
                }
                function g() {
                    i("responseText", ""), i("responseXML", null), i("response", null), i("status", 0), 
                    i("statusText", ""), E = b = null;
                }
                var x, v, w, y, E, b, _, R, A = this, I = {
                    timeout: 0,
                    readyState: h.UNSENT,
                    withCredentials: !1,
                    status: 0,
                    statusText: "",
                    responseType: "",
                    responseXML: null,
                    responseText: null,
                    response: null
                }, T = !0, S = {}, O = null, D = null, N = !1, C = !1, L = !1, M = !1, F = !1, B = !1, P = null, H = null, k = {}, U = "";
                e.extend(this, I, {
                    uid: e.guid("uid_"),
                    upload: new m(),
                    open: function(o, a, s, u, c) {
                        var l;
                        if (!o || !a) throw new t.DOMException(t.DOMException.SYNTAX_ERR);
                        if (/[\u0100-\uffff]/.test(o) || n.utf8_encode(o) !== o) throw new t.DOMException(t.DOMException.SYNTAX_ERR);
                        if (~e.inArray(o.toUpperCase(), [ "CONNECT", "DELETE", "GET", "HEAD", "OPTIONS", "POST", "PUT", "TRACE", "TRACK" ]) && (v = o.toUpperCase()), 
                        ~e.inArray(v, [ "CONNECT", "TRACE", "TRACK" ])) throw new t.DOMException(t.DOMException.SECURITY_ERR);
                        if (a = n.utf8_encode(a), l = r.parseUrl(a), B = r.hasSameOrigin(l), x = r.resolveUrl(a), 
                        (u || c) && !B) throw new t.DOMException(t.DOMException.INVALID_ACCESS_ERR);
                        if (w = u || l.user, y = c || l.pass, T = s || !0, T === !1 && (i("timeout") || i("withCredentials") || "" !== i("responseType"))) throw new t.DOMException(t.DOMException.INVALID_ACCESS_ERR);
                        N = !T, C = !1, S = {}, g.call(this), i("readyState", h.OPENED), this.dispatchEvent("readystatechange");
                    },
                    setRequestHeader: function(r, o) {
                        var a = [ "accept-charset", "accept-encoding", "access-control-request-headers", "access-control-request-method", "connection", "content-length", "cookie", "cookie2", "content-transfer-encoding", "date", "expect", "host", "keep-alive", "origin", "referer", "te", "trailer", "transfer-encoding", "upgrade", "user-agent", "via" ];
                        if (i("readyState") !== h.OPENED || C) throw new t.DOMException(t.DOMException.INVALID_STATE_ERR);
                        if (/[\u0100-\uffff]/.test(r) || n.utf8_encode(r) !== r) throw new t.DOMException(t.DOMException.SYNTAX_ERR);
                        return r = e.trim(r).toLowerCase(), ~e.inArray(r, a) || /^(proxy\-|sec\-)/.test(r) ? !1 : (S[r] ? S[r] += ", " + o : S[r] = o, 
                        !0);
                    },
                    hasRequestHeader: function(e) {
                        return e && S[e.toLowerCase()] || !1;
                    },
                    getAllResponseHeaders: function() {
                        return U || "";
                    },
                    getResponseHeader: function(t) {
                        return t = t.toLowerCase(), F || ~e.inArray(t, [ "set-cookie", "set-cookie2" ]) ? null : U && "" !== U && (R || (R = {}, 
                        e.each(U.split(/\r\n/), function(t) {
                            var i = t.split(/:\s+/);
                            2 === i.length && (i[0] = e.trim(i[0]), R[i[0].toLowerCase()] = {
                                header: i[0],
                                value: e.trim(i[1])
                            });
                        })), R.hasOwnProperty(t)) ? R[t].header + ": " + R[t].value : null;
                    },
                    overrideMimeType: function(n) {
                        var r, o;
                        if (~e.inArray(i("readyState"), [ h.LOADING, h.DONE ])) throw new t.DOMException(t.DOMException.INVALID_STATE_ERR);
                        if (n = e.trim(n.toLowerCase()), /;/.test(n) && (r = n.match(/^([^;]+)(?:;\scharset\=)?(.*)$/)) && (n = r[1], 
                        r[2] && (o = r[2])), !d.mimes[n]) throw new t.DOMException(t.DOMException.SYNTAX_ERR);
                        P = n, H = o;
                    },
                    send: function(i, r) {
                        if (k = "string" === e.typeOf(r) ? {
                            ruid: r
                        } : r ? r : {}, this.readyState !== h.OPENED || C) throw new t.DOMException(t.DOMException.INVALID_STATE_ERR);
                        if (i instanceof s) k.ruid = i.ruid, D = i.type || "application/octet-stream"; else if (i instanceof c) {
                            if (i.hasBlob()) {
                                var o = i.getBlob();
                                k.ruid = o.ruid, D = o.type || "application/octet-stream";
                            }
                        } else "string" == typeof i && (O = "UTF-8", D = "text/plain;charset=UTF-8", i = n.utf8_encode(i));
                        this.withCredentials || (this.withCredentials = k.required_caps && k.required_caps.send_browser_cookies && !B), 
                        L = !N && this.upload.hasEventListener(), F = !1, M = !i, N || (C = !0), u.call(this, i);
                    },
                    abort: function() {
                        if (F = !0, N = !1, ~e.inArray(i("readyState"), [ h.UNSENT, h.OPENED, h.DONE ])) i("readyState", h.UNSENT); else {
                            if (i("readyState", h.DONE), C = !1, !_) throw new t.DOMException(t.DOMException.INVALID_STATE_ERR);
                            _.getRuntime().exec.call(_, "XMLHttpRequest", "abort", M), M = !0;
                        }
                    },
                    destroy: function() {
                        _ && ("function" === e.typeOf(_.destroy) && _.destroy(), _ = null), this.unbindAll(), 
                        this.upload && (this.upload.unbindAll(), this.upload = null);
                    }
                }), this.handleEventProps(p.concat([ "readystatechange" ])), this.upload.handleEventProps(p);
            }
            var f = {
                100: "Continue",
                101: "Switching Protocols",
                102: "Processing",
                200: "OK",
                201: "Created",
                202: "Accepted",
                203: "Non-Authoritative Information",
                204: "No Content",
                205: "Reset Content",
                206: "Partial Content",
                207: "Multi-Status",
                226: "IM Used",
                300: "Multiple Choices",
                301: "Moved Permanently",
                302: "Found",
                303: "See Other",
                304: "Not Modified",
                305: "Use Proxy",
                306: "Reserved",
                307: "Temporary Redirect",
                400: "Bad Request",
                401: "Unauthorized",
                402: "Payment Required",
                403: "Forbidden",
                404: "Not Found",
                405: "Method Not Allowed",
                406: "Not Acceptable",
                407: "Proxy Authentication Required",
                408: "Request Timeout",
                409: "Conflict",
                410: "Gone",
                411: "Length Required",
                412: "Precondition Failed",
                413: "Request Entity Too Large",
                414: "Request-URI Too Long",
                415: "Unsupported Media Type",
                416: "Requested Range Not Satisfiable",
                417: "Expectation Failed",
                422: "Unprocessable Entity",
                423: "Locked",
                424: "Failed Dependency",
                426: "Upgrade Required",
                500: "Internal Server Error",
                501: "Not Implemented",
                502: "Bad Gateway",
                503: "Service Unavailable",
                504: "Gateway Timeout",
                505: "HTTP Version Not Supported",
                506: "Variant Also Negotiates",
                507: "Insufficient Storage",
                510: "Not Extended"
            };
            m.prototype = i.instance;
            var p = [ "loadstart", "progress", "abort", "error", "load", "timeout", "loadend" ];
            return h.UNSENT = 0, h.OPENED = 1, h.HEADERS_RECEIVED = 2, h.LOADING = 3, h.DONE = 4, 
            h.prototype = i.instance, h;
        }), n("moxie/runtime/Transporter", [ "moxie/core/utils/Basic", "moxie/core/utils/Encode", "moxie/runtime/RuntimeClient", "moxie/core/EventTarget" ], function(e, t, i, n) {
            function r() {
                function n() {
                    l = d = 0, c = this.result = null;
                }
                function o(t, i) {
                    var n = this;
                    u = i, n.bind("TransportingProgress", function(t) {
                        d = t.loaded, l > d && -1 === e.inArray(n.state, [ r.IDLE, r.DONE ]) && a.call(n);
                    }, 999), n.bind("TransportingComplete", function() {
                        d = l, n.state = r.DONE, c = null, n.result = u.exec.call(n, "Transporter", "getAsBlob", t || "");
                    }, 999), n.state = r.BUSY, n.trigger("TransportingStarted"), a.call(n);
                }
                function a() {
                    var e, i = this, n = l - d;
                    m > n && (m = n), e = t.btoa(c.substr(d, m)), u.exec.call(i, "Transporter", "receive", e, l);
                }
                var s, u, c, l, d, m;
                i.call(this), e.extend(this, {
                    uid: e.guid("uid_"),
                    state: r.IDLE,
                    result: null,
                    transport: function(t, i, r) {
                        var a = this;
                        if (r = e.extend({
                            chunk_size: 204798
                        }, r), (s = r.chunk_size % 3) && (r.chunk_size += 3 - s), m = r.chunk_size, n.call(this), 
                        c = t, l = t.length, "string" === e.typeOf(r) || r.ruid) o.call(a, i, this.connectRuntime(r)); else {
                            var u = function(e, t) {
                                a.unbind("RuntimeInit", u), o.call(a, i, t);
                            };
                            this.bind("RuntimeInit", u), this.connectRuntime(r);
                        }
                    },
                    abort: function() {
                        var e = this;
                        e.state = r.IDLE, u && (u.exec.call(e, "Transporter", "clear"), e.trigger("TransportingAborted")), 
                        n.call(e);
                    },
                    destroy: function() {
                        this.unbindAll(), u = null, this.disconnectRuntime(), n.call(this);
                    }
                });
            }
            return r.IDLE = 0, r.BUSY = 1, r.DONE = 2, r.prototype = n.instance, r;
        }), n("moxie/image/Image", [ "moxie/core/utils/Basic", "moxie/core/utils/Dom", "moxie/core/Exceptions", "moxie/file/FileReaderSync", "moxie/xhr/XMLHttpRequest", "moxie/runtime/Runtime", "moxie/runtime/RuntimeClient", "moxie/runtime/Transporter", "moxie/core/utils/Env", "moxie/core/EventTarget", "moxie/file/Blob", "moxie/file/File", "moxie/core/utils/Encode" ], function(e, t, i, n, r, o, a, s, u, c, l, d, m) {
            function h() {
                function n(e) {
                    try {
                        return e || (e = this.exec("Image", "getInfo")), this.size = e.size, this.width = e.width, 
                        this.height = e.height, this.type = e.type, this.meta = e.meta, "" === this.name && (this.name = e.name), 
                        !0;
                    } catch (t) {
                        return this.trigger("error", t.code), !1;
                    }
                }
                function c(t) {
                    var n = e.typeOf(t);
                    try {
                        if (t instanceof h) {
                            if (!t.size) throw new i.DOMException(i.DOMException.INVALID_STATE_ERR);
                            p.apply(this, arguments);
                        } else if (t instanceof l) {
                            if (!~e.inArray(t.type, [ "image/jpeg", "image/png" ])) throw new i.ImageError(i.ImageError.WRONG_FORMAT);
                            g.apply(this, arguments);
                        } else if (-1 !== e.inArray(n, [ "blob", "file" ])) c.call(this, new d(null, t), arguments[1]); else if ("string" === n) "data:" === t.substr(0, 5) ? c.call(this, new l(null, {
                            data: t
                        }), arguments[1]) : x.apply(this, arguments); else {
                            if ("node" !== n || "img" !== t.nodeName.toLowerCase()) throw new i.DOMException(i.DOMException.TYPE_MISMATCH_ERR);
                            c.call(this, t.src, arguments[1]);
                        }
                    } catch (r) {
                        this.trigger("error", r.code);
                    }
                }
                function p(t, i) {
                    var n = this.connectRuntime(t.ruid);
                    this.ruid = n.uid, n.exec.call(this, "Image", "loadFromImage", t, "undefined" === e.typeOf(i) ? !0 : i);
                }
                function g(t, i) {
                    function n(e) {
                        r.ruid = e.uid, e.exec.call(r, "Image", "loadFromBlob", t);
                    }
                    var r = this;
                    r.name = t.name || "", t.isDetached() ? (this.bind("RuntimeInit", function(e, t) {
                        n(t);
                    }), i && "string" == typeof i.required_caps && (i.required_caps = o.parseCaps(i.required_caps)), 
                    this.connectRuntime(e.extend({
                        required_caps: {
                            access_image_binary: !0,
                            resize_image: !0
                        }
                    }, i))) : n(this.connectRuntime(t.ruid));
                }
                function x(e, t) {
                    var i, n = this;
                    i = new r(), i.open("get", e), i.responseType = "blob", i.onprogress = function(e) {
                        n.trigger(e);
                    }, i.onload = function() {
                        g.call(n, i.response, !0);
                    }, i.onerror = function(e) {
                        n.trigger(e);
                    }, i.onloadend = function() {
                        i.destroy();
                    }, i.bind("RuntimeError", function(e, t) {
                        n.trigger("RuntimeError", t);
                    }), i.send(null, t);
                }
                a.call(this), e.extend(this, {
                    uid: e.guid("uid_"),
                    ruid: null,
                    name: "",
                    size: 0,
                    width: 0,
                    height: 0,
                    type: "",
                    meta: {},
                    clone: function() {
                        this.load.apply(this, arguments);
                    },
                    load: function() {
                        c.apply(this, arguments);
                    },
                    resize: function(t) {
                        var n, r, o = this, a = {
                            x: 0,
                            y: 0,
                            width: o.width,
                            height: o.height
                        }, s = e.extendIf({
                            width: o.width,
                            height: o.height,
                            type: o.type || "image/jpeg",
                            quality: 90,
                            crop: !1,
                            fit: !0,
                            preserveHeaders: !0,
                            resample: "default",
                            multipass: !0
                        }, t);
                        try {
                            if (!o.size) throw new i.DOMException(i.DOMException.INVALID_STATE_ERR);
                            if (o.width > h.MAX_RESIZE_WIDTH || o.height > h.MAX_RESIZE_HEIGHT) throw new i.ImageError(i.ImageError.MAX_RESOLUTION_ERR);
                            if (n = o.meta && o.meta.tiff && o.meta.tiff.Orientation || 1, -1 !== e.inArray(n, [ 5, 6, 7, 8 ])) {
                                var u = s.width;
                                s.width = s.height, s.height = u;
                            }
                            if (s.crop) {
                                switch (r = Math.max(s.width / o.width, s.height / o.height), t.fit ? (a.width = Math.min(Math.ceil(s.width / r), o.width), 
                                a.height = Math.min(Math.ceil(s.height / r), o.height), r = s.width / a.width) : (a.width = Math.min(s.width, o.width), 
                                a.height = Math.min(s.height, o.height), r = 1), "boolean" == typeof s.crop && (s.crop = "cc"), 
                                s.crop.toLowerCase().replace(/_/, "-")) {
                                  case "rb":
                                  case "right-bottom":
                                    a.x = o.width - a.width, a.y = o.height - a.height;
                                    break;

                                  case "cb":
                                  case "center-bottom":
                                    a.x = Math.floor((o.width - a.width) / 2), a.y = o.height - a.height;
                                    break;

                                  case "lb":
                                  case "left-bottom":
                                    a.x = 0, a.y = o.height - a.height;
                                    break;

                                  case "lt":
                                  case "left-top":
                                    a.x = 0, a.y = 0;
                                    break;

                                  case "ct":
                                  case "center-top":
                                    a.x = Math.floor((o.width - a.width) / 2), a.y = 0;
                                    break;

                                  case "rt":
                                  case "right-top":
                                    a.x = o.width - a.width, a.y = 0;
                                    break;

                                  case "rc":
                                  case "right-center":
                                  case "right-middle":
                                    a.x = o.width - a.width, a.y = Math.floor((o.height - a.height) / 2);
                                    break;

                                  case "lc":
                                  case "left-center":
                                  case "left-middle":
                                    a.x = 0, a.y = Math.floor((o.height - a.height) / 2);
                                    break;

                                  case "cc":
                                  case "center-center":
                                  case "center-middle":
                                  default:
                                    a.x = Math.floor((o.width - a.width) / 2), a.y = Math.floor((o.height - a.height) / 2);
                                }
                                a.x = Math.max(a.x, 0), a.y = Math.max(a.y, 0);
                            } else r = Math.min(s.width / o.width, s.height / o.height), r > 1 && !s.fit && (r = 1);
                            this.exec("Image", "resize", a, r, s);
                        } catch (c) {
                            o.trigger("error", c.code);
                        }
                    },
                    downsize: function(t) {
                        var i, n = {
                            width: this.width,
                            height: this.height,
                            type: this.type || "image/jpeg",
                            quality: 90,
                            crop: !1,
                            fit: !1,
                            preserveHeaders: !0,
                            resample: "default"
                        };
                        i = "object" == typeof t ? e.extend(n, t) : e.extend(n, {
                            width: arguments[0],
                            height: arguments[1],
                            crop: arguments[2],
                            preserveHeaders: arguments[3]
                        }), this.resize(i);
                    },
                    crop: function(e, t, i) {
                        this.downsize(e, t, !0, i);
                    },
                    getAsCanvas: function() {
                        if (!u.can("create_canvas")) throw new i.RuntimeError(i.RuntimeError.NOT_SUPPORTED_ERR);
                        return this.exec("Image", "getAsCanvas");
                    },
                    getAsBlob: function(e, t) {
                        if (!this.size) throw new i.DOMException(i.DOMException.INVALID_STATE_ERR);
                        return this.exec("Image", "getAsBlob", e || "image/jpeg", t || 90);
                    },
                    getAsDataURL: function(e, t) {
                        if (!this.size) throw new i.DOMException(i.DOMException.INVALID_STATE_ERR);
                        return this.exec("Image", "getAsDataURL", e || "image/jpeg", t || 90);
                    },
                    getAsBinaryString: function(e, t) {
                        var i = this.getAsDataURL(e, t);
                        return m.atob(i.substring(i.indexOf("base64,") + 7));
                    },
                    embed: function(n, r) {
                        function o(t, r) {
                            var o = this;
                            if (u.can("create_canvas")) {
                                var l = o.getAsCanvas();
                                if (l) return n.appendChild(l), l = null, o.destroy(), c.trigger("embedded"), void 0;
                            }
                            var d = o.getAsDataURL(t, r);
                            if (!d) throw new i.ImageError(i.ImageError.WRONG_FORMAT);
                            if (u.can("use_data_uri_of", d.length)) n.innerHTML = '<img src="' + d + '" width="' + o.width + '" height="' + o.height + '" alt="" />', 
                            o.destroy(), c.trigger("embedded"); else {
                                var h = new s();
                                h.bind("TransportingComplete", function() {
                                    a = c.connectRuntime(this.result.ruid), c.bind("Embedded", function() {
                                        e.extend(a.getShimContainer().style, {
                                            top: "0px",
                                            left: "0px",
                                            width: o.width + "px",
                                            height: o.height + "px"
                                        }), a = null;
                                    }, 999), a.exec.call(c, "ImageView", "display", this.result.uid, width, height), 
                                    o.destroy();
                                }), h.transport(m.atob(d.substring(d.indexOf("base64,") + 7)), t, {
                                    required_caps: {
                                        display_media: !0
                                    },
                                    runtime_order: "flash,silverlight",
                                    container: n
                                });
                            }
                        }
                        var a, c = this, l = e.extend({
                            width: this.width,
                            height: this.height,
                            type: this.type || "image/jpeg",
                            quality: 90,
                            fit: !0,
                            resample: "nearest"
                        }, r);
                        try {
                            if (!(n = t.get(n))) throw new i.DOMException(i.DOMException.INVALID_NODE_TYPE_ERR);
                            if (!this.size) throw new i.DOMException(i.DOMException.INVALID_STATE_ERR);
                            this.width > h.MAX_RESIZE_WIDTH || this.height > h.MAX_RESIZE_HEIGHT;
                            var d = new h();
                            return d.bind("Resize", function() {
                                o.call(this, l.type, l.quality);
                            }), d.bind("Load", function() {
                                this.downsize(l);
                            }), this.meta.thumb && this.meta.thumb.width >= l.width && this.meta.thumb.height >= l.height ? d.load(this.meta.thumb.data) : d.clone(this, !1), 
                            d;
                        } catch (f) {
                            this.trigger("error", f.code);
                        }
                    },
                    destroy: function() {
                        this.ruid && (this.getRuntime().exec.call(this, "Image", "destroy"), this.disconnectRuntime()), 
                        this.meta && this.meta.thumb && this.meta.thumb.data.destroy(), this.unbindAll();
                    }
                }), this.handleEventProps(f), this.bind("Load Resize", function() {
                    return n.call(this);
                }, 999);
            }
            var f = [ "progress", "load", "error", "resize", "embedded" ];
            return h.MAX_RESIZE_WIDTH = 8192, h.MAX_RESIZE_HEIGHT = 8192, h.prototype = c.instance, 
            h;
        }), n("moxie/runtime/html5/Runtime", [ "moxie/core/utils/Basic", "moxie/core/Exceptions", "moxie/runtime/Runtime", "moxie/core/utils/Env" ], function(e, t, i, n) {
            function o(t) {
                var o = this, u = i.capTest, c = i.capTrue, l = e.extend({
                    access_binary: u(window.FileReader || window.File && window.File.getAsDataURL),
                    access_image_binary: function() {
                        return o.can("access_binary") && !!s.Image;
                    },
                    display_media: u((n.can("create_canvas") || n.can("use_data_uri_over32kb")) && r("moxie/image/Image")),
                    do_cors: u(window.XMLHttpRequest && "withCredentials" in new XMLHttpRequest()),
                    drag_and_drop: u(function() {
                        var e = document.createElement("div");
                        return ("draggable" in e || "ondragstart" in e && "ondrop" in e) && ("IE" !== n.browser || n.verComp(n.version, 9, ">"));
                    }()),
                    filter_by_extension: u(function() {
                        return !("Chrome" === n.browser && n.verComp(n.version, 28, "<") || "IE" === n.browser && n.verComp(n.version, 10, "<") || "Safari" === n.browser && n.verComp(n.version, 7, "<") || "Firefox" === n.browser && n.verComp(n.version, 37, "<"));
                    }()),
                    return_response_headers: c,
                    return_response_type: function(e) {
                        return "json" === e && window.JSON ? !0 : n.can("return_response_type", e);
                    },
                    return_status_code: c,
                    report_upload_progress: u(window.XMLHttpRequest && new XMLHttpRequest().upload),
                    resize_image: function() {
                        return o.can("access_binary") && n.can("create_canvas");
                    },
                    select_file: function() {
                        return n.can("use_fileinput") && window.File;
                    },
                    select_folder: function() {
                        return o.can("select_file") && ("Chrome" === n.browser && n.verComp(n.version, 21, ">=") || "Firefox" === n.browser && n.verComp(n.version, 42, ">="));
                    },
                    select_multiple: function() {
                        return !(!o.can("select_file") || "Safari" === n.browser && "Windows" === n.os || "iOS" === n.os && n.verComp(n.osVersion, "7.0.0", ">") && n.verComp(n.osVersion, "8.0.0", "<"));
                    },
                    send_binary_string: u(window.XMLHttpRequest && (new XMLHttpRequest().sendAsBinary || window.Uint8Array && window.ArrayBuffer)),
                    send_custom_headers: u(window.XMLHttpRequest),
                    send_multipart: function() {
                        return !!(window.XMLHttpRequest && new XMLHttpRequest().upload && window.FormData) || o.can("send_binary_string");
                    },
                    slice_blob: u(window.File && (File.prototype.mozSlice || File.prototype.webkitSlice || File.prototype.slice)),
                    stream_upload: function() {
                        return o.can("slice_blob") && o.can("send_multipart");
                    },
                    summon_file_dialog: function() {
                        return o.can("select_file") && !("Firefox" === n.browser && n.verComp(n.version, 4, "<") || "Opera" === n.browser && n.verComp(n.version, 12, "<") || "IE" === n.browser && n.verComp(n.version, 10, "<"));
                    },
                    upload_filesize: c,
                    use_http_method: c
                }, arguments[2]);
                i.call(this, t, arguments[1] || a, l), e.extend(this, {
                    init: function() {
                        this.trigger("Init");
                    },
                    destroy: function(e) {
                        return function() {
                            e.call(o), e = o = null;
                        };
                    }(this.destroy)
                }), e.extend(this.getShim(), s);
            }
            var a = "html5", s = {};
            return i.addConstructor(a, o), s;
        }), n("moxie/runtime/html5/file/Blob", [ "moxie/runtime/html5/Runtime", "moxie/file/Blob" ], function(e, t) {
            function i() {
                function e(e, t, i) {
                    var n;
                    if (!window.File.prototype.slice) return (n = window.File.prototype.webkitSlice || window.File.prototype.mozSlice) ? n.call(e, t, i) : null;
                    try {
                        return e.slice(), e.slice(t, i);
                    } catch (r) {
                        return e.slice(t, i - t);
                    }
                }
                this.slice = function() {
                    return new t(this.getRuntime().uid, e.apply(this, arguments));
                }, this.destroy = function() {
                    this.getRuntime().getShim().removeInstance(this.uid);
                };
            }
            return e.Blob = i;
        }), n("moxie/core/utils/Events", [ "moxie/core/utils/Basic" ], function(e) {
            function t() {
                this.returnValue = !1;
            }
            function i() {
                this.cancelBubble = !0;
            }
            var n = {}, r = "moxie_" + e.guid(), o = function(o, a, s, u) {
                var c, l;
                a = a.toLowerCase(), o.addEventListener ? (c = s, o.addEventListener(a, c, !1)) : o.attachEvent && (c = function() {
                    var e = window.event;
                    e.target || (e.target = e.srcElement), e.preventDefault = t, e.stopPropagation = i, 
                    s(e);
                }, o.attachEvent("on" + a, c)), o[r] || (o[r] = e.guid()), n.hasOwnProperty(o[r]) || (n[o[r]] = {}), 
                l = n[o[r]], l.hasOwnProperty(a) || (l[a] = []), l[a].push({
                    func: c,
                    orig: s,
                    key: u
                });
            }, a = function(t, i, o) {
                var a, s;
                if (i = i.toLowerCase(), t[r] && n[t[r]] && n[t[r]][i]) {
                    a = n[t[r]][i];
                    for (var u = a.length - 1; u >= 0 && (a[u].orig !== o && a[u].key !== o || (t.removeEventListener ? t.removeEventListener(i, a[u].func, !1) : t.detachEvent && t.detachEvent("on" + i, a[u].func), 
                    a[u].orig = null, a[u].func = null, a.splice(u, 1), o === s)); u--) ;
                    if (a.length || delete n[t[r]][i], e.isEmptyObj(n[t[r]])) {
                        delete n[t[r]];
                        try {
                            delete t[r];
                        } catch (c) {
                            t[r] = s;
                        }
                    }
                }
            }, s = function(t, i) {
                t && t[r] && e.each(n[t[r]], function(e, n) {
                    a(t, n, i);
                });
            };
            return {
                addEvent: o,
                removeEvent: a,
                removeAllEvents: s
            };
        }), n("moxie/runtime/html5/file/FileInput", [ "moxie/runtime/html5/Runtime", "moxie/file/File", "moxie/core/utils/Basic", "moxie/core/utils/Dom", "moxie/core/utils/Events", "moxie/core/utils/Mime", "moxie/core/utils/Env" ], function(e, t, i, n, r, o, a) {
            function s() {
                var e, s;
                i.extend(this, {
                    init: function(u) {
                        var c, l, d, m, h, f, p = this, g = p.getRuntime();
                        e = u, d = o.extList2mimes(e.accept, g.can("filter_by_extension")), l = g.getShimContainer(), 
                        l.innerHTML = '<input id="' + g.uid + '" type="file" style="font-size:999px;opacity:0;"' + (e.multiple && g.can("select_multiple") ? "multiple" : "") + (e.directory && g.can("select_folder") ? "webkitdirectory directory" : "") + (d ? ' accept="' + d.join(",") + '"' : "") + " />", 
                        c = n.get(g.uid), i.extend(c.style, {
                            position: "absolute",
                            top: 0,
                            left: 0,
                            width: "100%",
                            height: "100%"
                        }), m = n.get(e.browse_button), s = n.getStyle(m, "z-index") || "auto", g.can("summon_file_dialog") && ("static" === n.getStyle(m, "position") && (m.style.position = "relative"), 
                        r.addEvent(m, "click", function(e) {
                            var t = n.get(g.uid);
                            t && !t.disabled && t.click(), e.preventDefault();
                        }, p.uid), p.bind("Refresh", function() {
                            h = parseInt(s, 10) || 1, n.get(e.browse_button).style.zIndex = h, this.getRuntime().getShimContainer().style.zIndex = h - 1;
                        })), f = g.can("summon_file_dialog") ? m : l, r.addEvent(f, "mouseover", function() {
                            p.trigger("mouseenter");
                        }, p.uid), r.addEvent(f, "mouseout", function() {
                            p.trigger("mouseleave");
                        }, p.uid), r.addEvent(f, "mousedown", function() {
                            p.trigger("mousedown");
                        }, p.uid), r.addEvent(n.get(e.container), "mouseup", function() {
                            p.trigger("mouseup");
                        }, p.uid), (g.can("summon_file_dialog") ? c : m).setAttribute("tabindex", -1), c.onchange = function x() {
                            if (p.files = [], i.each(this.files, function(i) {
                                var n = "";
                                return e.directory && "." == i.name ? !0 : (i.webkitRelativePath && (n = "/" + i.webkitRelativePath.replace(/^\//, "")), 
                                i = new t(g.uid, i), i.relativePath = n, p.files.push(i), void 0);
                            }), "IE" !== a.browser && "IEMobile" !== a.browser) this.value = ""; else {
                                var n = this.cloneNode(!0);
                                this.parentNode.replaceChild(n, this), n.onchange = x;
                            }
                            p.files.length && p.trigger("change");
                        }, p.trigger({
                            type: "ready",
                            async: !0
                        }), l = null;
                    },
                    setOption: function(e, t) {
                        var i = this.getRuntime(), r = n.get(i.uid);
                        switch (e) {
                          case "accept":
                            if (t) {
                                var a = t.mimes || o.extList2mimes(t, i.can("filter_by_extension"));
                                r.setAttribute("accept", a.join(","));
                            } else r.removeAttribute("accept");
                            break;

                          case "directory":
                            t && i.can("select_folder") ? (r.setAttribute("directory", ""), r.setAttribute("webkitdirectory", "")) : (r.removeAttribute("directory"), 
                            r.removeAttribute("webkitdirectory"));
                            break;

                          case "multiple":
                            t && i.can("select_multiple") ? r.setAttribute("multiple", "") : r.removeAttribute("multiple");
                        }
                    },
                    disable: function(e) {
                        var t, i = this.getRuntime();
                        (t = n.get(i.uid)) && (t.disabled = !!e);
                    },
                    destroy: function() {
                        var t = this.getRuntime(), i = t.getShim(), o = t.getShimContainer(), a = e && n.get(e.container), u = e && n.get(e.browse_button);
                        a && r.removeAllEvents(a, this.uid), u && (r.removeAllEvents(u, this.uid), u.style.zIndex = s), 
                        o && (r.removeAllEvents(o, this.uid), o.innerHTML = ""), i.removeInstance(this.uid), 
                        e = o = a = u = i = null;
                    }
                });
            }
            return e.FileInput = s;
        }), n("moxie/runtime/html5/file/FileDrop", [ "moxie/runtime/html5/Runtime", "moxie/file/File", "moxie/core/utils/Basic", "moxie/core/utils/Dom", "moxie/core/utils/Events", "moxie/core/utils/Mime" ], function(e, t, i, n, r, o) {
            function a() {
                function e(e) {
                    if (!e.dataTransfer || !e.dataTransfer.types) return !1;
                    var t = i.toArray(e.dataTransfer.types || []);
                    return -1 !== i.inArray("Files", t) || -1 !== i.inArray("public.file-url", t) || -1 !== i.inArray("application/x-moz-file", t);
                }
                function a(e, i) {
                    if (u(e)) {
                        var n = new t(f, e);
                        n.relativePath = i || "", p.push(n);
                    }
                }
                function s(e) {
                    for (var t = [], n = 0; n < e.length; n++) [].push.apply(t, e[n].extensions.split(/\s*,\s*/));
                    return -1 === i.inArray("*", t) ? t : [];
                }
                function u(e) {
                    if (!g.length) return !0;
                    var t = o.getFileExtension(e.name);
                    return !t || -1 !== i.inArray(t, g);
                }
                function c(e, t) {
                    var n = [];
                    i.each(e, function(e) {
                        var t = e.webkitGetAsEntry();
                        t && (t.isFile ? a(e.getAsFile(), t.fullPath) : n.push(t));
                    }), n.length ? l(n, t) : t();
                }
                function l(e, t) {
                    var n = [];
                    i.each(e, function(e) {
                        n.push(function(t) {
                            d(e, t);
                        });
                    }), i.inSeries(n, function() {
                        t();
                    });
                }
                function d(e, t) {
                    e.isFile ? e.file(function(i) {
                        a(i, e.fullPath), t();
                    }, function() {
                        t();
                    }) : e.isDirectory ? m(e, t) : t();
                }
                function m(e, t) {
                    function i(e) {
                        r.readEntries(function(t) {
                            t.length ? ([].push.apply(n, t), i(e)) : e();
                        }, e);
                    }
                    var n = [], r = e.createReader();
                    i(function() {
                        l(n, t);
                    });
                }
                var h, f, p = [], g = [];
                i.extend(this, {
                    init: function(t) {
                        var n, o = this;
                        h = t, f = o.ruid, g = s(h.accept), n = h.container, r.addEvent(n, "dragover", function(t) {
                            e(t) && (t.preventDefault(), t.dataTransfer.dropEffect = "copy");
                        }, o.uid), r.addEvent(n, "drop", function(t) {
                            e(t) && (t.preventDefault(), p = [], t.dataTransfer.items && t.dataTransfer.items[0].webkitGetAsEntry ? c(t.dataTransfer.items, function() {
                                o.files = p, o.trigger("drop");
                            }) : (i.each(t.dataTransfer.files, function(e) {
                                a(e);
                            }), o.files = p, o.trigger("drop")));
                        }, o.uid), r.addEvent(n, "dragenter", function() {
                            o.trigger("dragenter");
                        }, o.uid), r.addEvent(n, "dragleave", function() {
                            o.trigger("dragleave");
                        }, o.uid);
                    },
                    destroy: function() {
                        r.removeAllEvents(h && n.get(h.container), this.uid), f = p = g = h = null, this.getRuntime().getShim().removeInstance(this.uid);
                    }
                });
            }
            return e.FileDrop = a;
        }), n("moxie/runtime/html5/file/FileReader", [ "moxie/runtime/html5/Runtime", "moxie/core/utils/Encode", "moxie/core/utils/Basic" ], function(e, t, i) {
            function n() {
                function e(e) {
                    return t.atob(e.substring(e.indexOf("base64,") + 7));
                }
                var n, r = !1;
                i.extend(this, {
                    read: function(t, o) {
                        var a = this;
                        a.result = "", n = new window.FileReader(), n.addEventListener("progress", function(e) {
                            a.trigger(e);
                        }), n.addEventListener("load", function(t) {
                            a.result = r ? e(n.result) : n.result, a.trigger(t);
                        }), n.addEventListener("error", function(e) {
                            a.trigger(e, n.error);
                        }), n.addEventListener("loadend", function(e) {
                            n = null, a.trigger(e);
                        }), "function" === i.typeOf(n[t]) ? (r = !1, n[t](o.getSource())) : "readAsBinaryString" === t && (r = !0, 
                        n.readAsDataURL(o.getSource()));
                    },
                    abort: function() {
                        n && n.abort();
                    },
                    destroy: function() {
                        n = null, this.getRuntime().getShim().removeInstance(this.uid);
                    }
                });
            }
            return e.FileReader = n;
        }), n("moxie/runtime/html5/xhr/XMLHttpRequest", [ "moxie/runtime/html5/Runtime", "moxie/core/utils/Basic", "moxie/core/utils/Mime", "moxie/core/utils/Url", "moxie/file/File", "moxie/file/Blob", "moxie/xhr/FormData", "moxie/core/Exceptions", "moxie/core/utils/Env" ], function(e, t, i, n, r, o, a, s, u) {
            function c() {
                function e(e, t) {
                    var i, n, r = this;
                    i = t.getBlob().getSource(), n = new window.FileReader(), n.onload = function() {
                        t.append(t.getBlobName(), new o(null, {
                            type: i.type,
                            data: n.result
                        })), f.send.call(r, e, t);
                    }, n.readAsBinaryString(i);
                }
                function c() {
                    return !window.XMLHttpRequest || "IE" === u.browser && u.verComp(u.version, 8, "<") ? function() {
                        for (var e = [ "Msxml2.XMLHTTP.6.0", "Microsoft.XMLHTTP" ], t = 0; t < e.length; t++) try {
                            return new ActiveXObject(e[t]);
                        } catch (i) {}
                    }() : new window.XMLHttpRequest();
                }
                function l(e) {
                    var t = e.responseXML, i = e.responseText;
                    return "IE" === u.browser && i && t && !t.documentElement && /[^\/]+\/[^\+]+\+xml/.test(e.getResponseHeader("Content-Type")) && (t = new window.ActiveXObject("Microsoft.XMLDOM"), 
                    t.async = !1, t.validateOnParse = !1, t.loadXML(i)), t && ("IE" === u.browser && 0 !== t.parseError || !t.documentElement || "parsererror" === t.documentElement.tagName) ? null : t;
                }
                function d(e) {
                    var t = "----moxieboundary" + new Date().getTime(), i = "--", n = "\r\n", r = "", a = this.getRuntime();
                    if (!a.can("send_binary_string")) throw new s.RuntimeError(s.RuntimeError.NOT_SUPPORTED_ERR);
                    return m.setRequestHeader("Content-Type", "multipart/form-data; boundary=" + t), 
                    e.each(function(e, a) {
                        r += e instanceof o ? i + t + n + 'Content-Disposition: form-data; name="' + a + '"; filename="' + unescape(encodeURIComponent(e.name || "blob")) + '"' + n + "Content-Type: " + (e.type || "application/octet-stream") + n + n + e.getSource() + n : i + t + n + 'Content-Disposition: form-data; name="' + a + '"' + n + n + unescape(encodeURIComponent(e)) + n;
                    }), r += i + t + i + n;
                }
                var m, h, f = this;
                t.extend(this, {
                    send: function(i, r) {
                        var s = this, l = "Mozilla" === u.browser && u.verComp(u.version, 4, ">=") && u.verComp(u.version, 7, "<"), f = "Android Browser" === u.browser, p = !1;
                        if (h = i.url.replace(/^.+?\/([\w\-\.]+)$/, "$1").toLowerCase(), m = c(), m.open(i.method, i.url, i.async, i.user, i.password), 
                        r instanceof o) r.isDetached() && (p = !0), r = r.getSource(); else if (r instanceof a) {
                            if (r.hasBlob()) if (r.getBlob().isDetached()) r = d.call(s, r), p = !0; else if ((l || f) && "blob" === t.typeOf(r.getBlob().getSource()) && window.FileReader) return e.call(s, i, r), 
                            void 0;
                            if (r instanceof a) {
                                var g = new window.FormData();
                                r.each(function(e, t) {
                                    e instanceof o ? g.append(t, e.getSource()) : g.append(t, e);
                                }), r = g;
                            }
                        }
                        m.upload ? (i.withCredentials && (m.withCredentials = !0), m.addEventListener("load", function(e) {
                            s.trigger(e);
                        }), m.addEventListener("error", function(e) {
                            s.trigger(e);
                        }), m.addEventListener("progress", function(e) {
                            s.trigger(e);
                        }), m.upload.addEventListener("progress", function(e) {
                            s.trigger({
                                type: "UploadProgress",
                                loaded: e.loaded,
                                total: e.total
                            });
                        })) : m.onreadystatechange = function() {
                            switch (m.readyState) {
                              case 1:
                                break;

                              case 2:
                                break;

                              case 3:
                                var e, t;
                                try {
                                    n.hasSameOrigin(i.url) && (e = m.getResponseHeader("Content-Length") || 0), m.responseText && (t = m.responseText.length);
                                } catch (r) {
                                    e = t = 0;
                                }
                                s.trigger({
                                    type: "progress",
                                    lengthComputable: !!e,
                                    total: parseInt(e, 10),
                                    loaded: t
                                });
                                break;

                              case 4:
                                m.onreadystatechange = function() {};
                                try {
                                    if (m.status >= 200 && m.status < 400) {
                                        s.trigger("load");
                                        break;
                                    }
                                } catch (r) {}
                                s.trigger("error");
                            }
                        }, t.isEmptyObj(i.headers) || t.each(i.headers, function(e, t) {
                            m.setRequestHeader(t, e);
                        }), "" !== i.responseType && "responseType" in m && (m.responseType = "json" !== i.responseType || u.can("return_response_type", "json") ? i.responseType : "text"), 
                        p ? m.sendAsBinary ? m.sendAsBinary(r) : function() {
                            for (var e = new Uint8Array(r.length), t = 0; t < r.length; t++) e[t] = 255 & r.charCodeAt(t);
                            m.send(e.buffer);
                        }() : m.send(r), s.trigger("loadstart");
                    },
                    getStatus: function() {
                        try {
                            if (m) return m.status;
                        } catch (e) {}
                        return 0;
                    },
                    getResponse: function(e) {
                        var t = this.getRuntime();
                        try {
                            switch (e) {
                              case "blob":
                                var n = new r(t.uid, m.response), o = m.getResponseHeader("Content-Disposition");
                                if (o) {
                                    var a = o.match(/filename=([\'\"'])([^\1]+)\1/);
                                    a && (h = a[2]);
                                }
                                return n.name = h, n.type || (n.type = i.getFileMime(h)), n;

                              case "json":
                                return u.can("return_response_type", "json") ? m.response : 200 === m.status && window.JSON ? JSON.parse(m.responseText) : null;

                              case "document":
                                return l(m);

                              default:
                                return "" !== m.responseText ? m.responseText : null;
                            }
                        } catch (s) {
                            return null;
                        }
                    },
                    getAllResponseHeaders: function() {
                        try {
                            return m.getAllResponseHeaders();
                        } catch (e) {}
                        return "";
                    },
                    abort: function() {
                        m && m.abort();
                    },
                    destroy: function() {
                        f = h = null, this.getRuntime().getShim().removeInstance(this.uid);
                    }
                });
            }
            return e.XMLHttpRequest = c;
        }), n("moxie/runtime/html5/utils/BinaryReader", [ "moxie/core/utils/Basic" ], function(e) {
            function t(e) {
                e instanceof ArrayBuffer ? i.apply(this, arguments) : n.apply(this, arguments);
            }
            function i(t) {
                var i = new DataView(t);
                e.extend(this, {
                    readByteAt: function(e) {
                        return i.getUint8(e);
                    },
                    writeByteAt: function(e, t) {
                        i.setUint8(e, t);
                    },
                    SEGMENT: function(e, n, r) {
                        switch (arguments.length) {
                          case 2:
                            return t.slice(e, e + n);

                          case 1:
                            return t.slice(e);

                          case 3:
                            if (null === r && (r = new ArrayBuffer()), r instanceof ArrayBuffer) {
                                var o = new Uint8Array(this.length() - n + r.byteLength);
                                e > 0 && o.set(new Uint8Array(t.slice(0, e)), 0), o.set(new Uint8Array(r), e), o.set(new Uint8Array(t.slice(e + n)), e + r.byteLength), 
                                this.clear(), t = o.buffer, i = new DataView(t);
                                break;
                            }

                          default:
                            return t;
                        }
                    },
                    length: function() {
                        return t ? t.byteLength : 0;
                    },
                    clear: function() {
                        i = t = null;
                    }
                });
            }
            function n(t) {
                function i(e, i, n) {
                    n = 3 === arguments.length ? n : t.length - i - 1, t = t.substr(0, i) + e + t.substr(n + i);
                }
                e.extend(this, {
                    readByteAt: function(e) {
                        return t.charCodeAt(e);
                    },
                    writeByteAt: function(e, t) {
                        i(String.fromCharCode(t), e, 1);
                    },
                    SEGMENT: function(e, n, r) {
                        switch (arguments.length) {
                          case 1:
                            return t.substr(e);

                          case 2:
                            return t.substr(e, n);

                          case 3:
                            i(null !== r ? r : "", e, n);
                            break;

                          default:
                            return t;
                        }
                    },
                    length: function() {
                        return t ? t.length : 0;
                    },
                    clear: function() {
                        t = null;
                    }
                });
            }
            return e.extend(t.prototype, {
                littleEndian: !1,
                read: function(e, t) {
                    var i, n, r;
                    if (e + t > this.length()) throw new Error("You are trying to read outside the source boundaries.");
                    for (n = this.littleEndian ? 0 : -8 * (t - 1), r = 0, i = 0; t > r; r++) i |= this.readByteAt(e + r) << Math.abs(n + 8 * r);
                    return i;
                },
                write: function(e, t, i) {
                    var n, r;
                    if (e > this.length()) throw new Error("You are trying to write outside the source boundaries.");
                    for (n = this.littleEndian ? 0 : -8 * (i - 1), r = 0; i > r; r++) this.writeByteAt(e + r, 255 & t >> Math.abs(n + 8 * r));
                },
                BYTE: function(e) {
                    return this.read(e, 1);
                },
                SHORT: function(e) {
                    return this.read(e, 2);
                },
                LONG: function(e) {
                    return this.read(e, 4);
                },
                SLONG: function(e) {
                    var t = this.read(e, 4);
                    return t > 2147483647 ? t - 4294967296 : t;
                },
                CHAR: function(e) {
                    return String.fromCharCode(this.read(e, 1));
                },
                STRING: function(e, t) {
                    return this.asArray("CHAR", e, t).join("");
                },
                asArray: function(e, t, i) {
                    for (var n = [], r = 0; i > r; r++) n[r] = this[e](t + r);
                    return n;
                }
            }), t;
        }), n("moxie/runtime/html5/image/JPEGHeaders", [ "moxie/runtime/html5/utils/BinaryReader", "moxie/core/Exceptions" ], function(e, t) {
            return function i(n) {
                var r, o, a, s = [], u = 0;
                if (r = new e(n), 65496 !== r.SHORT(0)) throw r.clear(), new t.ImageError(t.ImageError.WRONG_FORMAT);
                for (o = 2; o <= r.length(); ) if (a = r.SHORT(o), a >= 65488 && 65495 >= a) o += 2; else {
                    if (65498 === a || 65497 === a) break;
                    u = r.SHORT(o + 2) + 2, a >= 65505 && 65519 >= a && s.push({
                        hex: a,
                        name: "APP" + (15 & a),
                        start: o,
                        length: u,
                        segment: r.SEGMENT(o, u)
                    }), o += u;
                }
                return r.clear(), {
                    headers: s,
                    restore: function(t) {
                        var i, n, r;
                        for (r = new e(t), o = 65504 == r.SHORT(2) ? 4 + r.SHORT(4) : 2, n = 0, i = s.length; i > n; n++) r.SEGMENT(o, 0, s[n].segment), 
                        o += s[n].length;
                        return t = r.SEGMENT(), r.clear(), t;
                    },
                    strip: function(t) {
                        var n, r, o, a;
                        for (o = new i(t), r = o.headers, o.purge(), n = new e(t), a = r.length; a--; ) n.SEGMENT(r[a].start, r[a].length, "");
                        return t = n.SEGMENT(), n.clear(), t;
                    },
                    get: function(e) {
                        for (var t = [], i = 0, n = s.length; n > i; i++) s[i].name === e.toUpperCase() && t.push(s[i].segment);
                        return t;
                    },
                    set: function(e, t) {
                        var i, n, r, o = [];
                        for ("string" == typeof t ? o.push(t) : o = t, i = n = 0, r = s.length; r > i && (s[i].name === e.toUpperCase() && (s[i].segment = o[n], 
                        s[i].length = o[n].length, n++), !(n >= o.length)); i++) ;
                    },
                    purge: function() {
                        this.headers = s = [];
                    }
                };
            };
        }), n("moxie/runtime/html5/image/ExifParser", [ "moxie/core/utils/Basic", "moxie/runtime/html5/utils/BinaryReader", "moxie/core/Exceptions" ], function(e, i, n) {
            function r(o) {
                function a(i, r) {
                    var o, a, s, u, c, m, h, f, p = this, g = [], x = {}, v = {
                        1: "BYTE",
                        7: "UNDEFINED",
                        2: "ASCII",
                        3: "SHORT",
                        4: "LONG",
                        5: "RATIONAL",
                        9: "SLONG",
                        10: "SRATIONAL"
                    }, w = {
                        BYTE: 1,
                        UNDEFINED: 1,
                        ASCII: 1,
                        SHORT: 2,
                        LONG: 4,
                        RATIONAL: 8,
                        SLONG: 4,
                        SRATIONAL: 8
                    };
                    for (o = p.SHORT(i), a = 0; o > a; a++) if (g = [], h = i + 2 + 12 * a, s = r[p.SHORT(h)], 
                    s !== t) {
                        if (u = v[p.SHORT(h += 2)], c = p.LONG(h += 2), m = w[u], !m) throw new n.ImageError(n.ImageError.INVALID_META_ERR);
                        if (h += 4, m * c > 4 && (h = p.LONG(h) + d.tiffHeader), h + m * c >= this.length()) throw new n.ImageError(n.ImageError.INVALID_META_ERR);
                        "ASCII" !== u ? (g = p.asArray(u, h, c), f = 1 == c ? g[0] : g, x[s] = l.hasOwnProperty(s) && "object" != typeof f ? l[s][f] : f) : x[s] = e.trim(p.STRING(h, c).replace(/\0$/, ""));
                    }
                    return x;
                }
                function s(e, t, i) {
                    var n, r, o, a = 0;
                    if ("string" == typeof t) {
                        var s = c[e.toLowerCase()];
                        for (var u in s) if (s[u] === t) {
                            t = u;
                            break;
                        }
                    }
                    n = d[e.toLowerCase() + "IFD"], r = this.SHORT(n);
                    for (var l = 0; r > l; l++) if (o = n + 12 * l + 2, this.SHORT(o) == t) {
                        a = o + 8;
                        break;
                    }
                    if (!a) return !1;
                    try {
                        this.write(a, i, 4);
                    } catch (m) {
                        return !1;
                    }
                    return !0;
                }
                var u, c, l, d, m, h;
                if (i.call(this, o), c = {
                    tiff: {
                        274: "Orientation",
                        270: "ImageDescription",
                        271: "Make",
                        272: "Model",
                        305: "Software",
                        34665: "ExifIFDPointer",
                        34853: "GPSInfoIFDPointer"
                    },
                    exif: {
                        36864: "ExifVersion",
                        40961: "ColorSpace",
                        40962: "PixelXDimension",
                        40963: "PixelYDimension",
                        36867: "DateTimeOriginal",
                        33434: "ExposureTime",
                        33437: "FNumber",
                        34855: "ISOSpeedRatings",
                        37377: "ShutterSpeedValue",
                        37378: "ApertureValue",
                        37383: "MeteringMode",
                        37384: "LightSource",
                        37385: "Flash",
                        37386: "FocalLength",
                        41986: "ExposureMode",
                        41987: "WhiteBalance",
                        41990: "SceneCaptureType",
                        41988: "DigitalZoomRatio",
                        41992: "Contrast",
                        41993: "Saturation",
                        41994: "Sharpness"
                    },
                    gps: {
                        0: "GPSVersionID",
                        1: "GPSLatitudeRef",
                        2: "GPSLatitude",
                        3: "GPSLongitudeRef",
                        4: "GPSLongitude"
                    },
                    thumb: {
                        513: "JPEGInterchangeFormat",
                        514: "JPEGInterchangeFormatLength"
                    }
                }, l = {
                    ColorSpace: {
                        1: "sRGB",
                        0: "Uncalibrated"
                    },
                    MeteringMode: {
                        0: "Unknown",
                        1: "Average",
                        2: "CenterWeightedAverage",
                        3: "Spot",
                        4: "MultiSpot",
                        5: "Pattern",
                        6: "Partial",
                        255: "Other"
                    },
                    LightSource: {
                        1: "Daylight",
                        2: "Fliorescent",
                        3: "Tungsten",
                        4: "Flash",
                        9: "Fine weather",
                        10: "Cloudy weather",
                        11: "Shade",
                        12: "Daylight fluorescent (D 5700 - 7100K)",
                        13: "Day white fluorescent (N 4600 -5400K)",
                        14: "Cool white fluorescent (W 3900 - 4500K)",
                        15: "White fluorescent (WW 3200 - 3700K)",
                        17: "Standard light A",
                        18: "Standard light B",
                        19: "Standard light C",
                        20: "D55",
                        21: "D65",
                        22: "D75",
                        23: "D50",
                        24: "ISO studio tungsten",
                        255: "Other"
                    },
                    Flash: {
                        0: "Flash did not fire",
                        1: "Flash fired",
                        5: "Strobe return light not detected",
                        7: "Strobe return light detected",
                        9: "Flash fired, compulsory flash mode",
                        13: "Flash fired, compulsory flash mode, return light not detected",
                        15: "Flash fired, compulsory flash mode, return light detected",
                        16: "Flash did not fire, compulsory flash mode",
                        24: "Flash did not fire, auto mode",
                        25: "Flash fired, auto mode",
                        29: "Flash fired, auto mode, return light not detected",
                        31: "Flash fired, auto mode, return light detected",
                        32: "No flash function",
                        65: "Flash fired, red-eye reduction mode",
                        69: "Flash fired, red-eye reduction mode, return light not detected",
                        71: "Flash fired, red-eye reduction mode, return light detected",
                        73: "Flash fired, compulsory flash mode, red-eye reduction mode",
                        77: "Flash fired, compulsory flash mode, red-eye reduction mode, return light not detected",
                        79: "Flash fired, compulsory flash mode, red-eye reduction mode, return light detected",
                        89: "Flash fired, auto mode, red-eye reduction mode",
                        93: "Flash fired, auto mode, return light not detected, red-eye reduction mode",
                        95: "Flash fired, auto mode, return light detected, red-eye reduction mode"
                    },
                    ExposureMode: {
                        0: "Auto exposure",
                        1: "Manual exposure",
                        2: "Auto bracket"
                    },
                    WhiteBalance: {
                        0: "Auto white balance",
                        1: "Manual white balance"
                    },
                    SceneCaptureType: {
                        0: "Standard",
                        1: "Landscape",
                        2: "Portrait",
                        3: "Night scene"
                    },
                    Contrast: {
                        0: "Normal",
                        1: "Soft",
                        2: "Hard"
                    },
                    Saturation: {
                        0: "Normal",
                        1: "Low saturation",
                        2: "High saturation"
                    },
                    Sharpness: {
                        0: "Normal",
                        1: "Soft",
                        2: "Hard"
                    },
                    GPSLatitudeRef: {
                        N: "North latitude",
                        S: "South latitude"
                    },
                    GPSLongitudeRef: {
                        E: "East longitude",
                        W: "West longitude"
                    }
                }, d = {
                    tiffHeader: 10
                }, m = d.tiffHeader, u = {
                    clear: this.clear
                }, e.extend(this, {
                    read: function() {
                        try {
                            return r.prototype.read.apply(this, arguments);
                        } catch (e) {
                            throw new n.ImageError(n.ImageError.INVALID_META_ERR);
                        }
                    },
                    write: function() {
                        try {
                            return r.prototype.write.apply(this, arguments);
                        } catch (e) {
                            throw new n.ImageError(n.ImageError.INVALID_META_ERR);
                        }
                    },
                    UNDEFINED: function() {
                        return this.BYTE.apply(this, arguments);
                    },
                    RATIONAL: function(e) {
                        return this.LONG(e) / this.LONG(e + 4);
                    },
                    SRATIONAL: function(e) {
                        return this.SLONG(e) / this.SLONG(e + 4);
                    },
                    ASCII: function(e) {
                        return this.CHAR(e);
                    },
                    TIFF: function() {
                        return h || null;
                    },
                    EXIF: function() {
                        var t = null;
                        if (d.exifIFD) {
                            try {
                                t = a.call(this, d.exifIFD, c.exif);
                            } catch (i) {
                                return null;
                            }
                            if (t.ExifVersion && "array" === e.typeOf(t.ExifVersion)) {
                                for (var n = 0, r = ""; n < t.ExifVersion.length; n++) r += String.fromCharCode(t.ExifVersion[n]);
                                t.ExifVersion = r;
                            }
                        }
                        return t;
                    },
                    GPS: function() {
                        var t = null;
                        if (d.gpsIFD) {
                            try {
                                t = a.call(this, d.gpsIFD, c.gps);
                            } catch (i) {
                                return null;
                            }
                            t.GPSVersionID && "array" === e.typeOf(t.GPSVersionID) && (t.GPSVersionID = t.GPSVersionID.join("."));
                        }
                        return t;
                    },
                    thumb: function() {
                        if (d.IFD1) try {
                            var e = a.call(this, d.IFD1, c.thumb);
                            if ("JPEGInterchangeFormat" in e) return this.SEGMENT(d.tiffHeader + e.JPEGInterchangeFormat, e.JPEGInterchangeFormatLength);
                        } catch (t) {}
                        return null;
                    },
                    setExif: function(e, t) {
                        return "PixelXDimension" !== e && "PixelYDimension" !== e ? !1 : s.call(this, "exif", e, t);
                    },
                    clear: function() {
                        u.clear(), o = c = l = h = d = u = null;
                    }
                }), 65505 !== this.SHORT(0) || "EXIF\0" !== this.STRING(4, 5).toUpperCase()) throw new n.ImageError(n.ImageError.INVALID_META_ERR);
                if (this.littleEndian = 18761 == this.SHORT(m), 42 !== this.SHORT(m += 2)) throw new n.ImageError(n.ImageError.INVALID_META_ERR);
                d.IFD0 = d.tiffHeader + this.LONG(m += 2), h = a.call(this, d.IFD0, c.tiff), "ExifIFDPointer" in h && (d.exifIFD = d.tiffHeader + h.ExifIFDPointer, 
                delete h.ExifIFDPointer), "GPSInfoIFDPointer" in h && (d.gpsIFD = d.tiffHeader + h.GPSInfoIFDPointer, 
                delete h.GPSInfoIFDPointer), e.isEmptyObj(h) && (h = null);
                var f = this.LONG(d.IFD0 + 12 * this.SHORT(d.IFD0) + 2);
                f && (d.IFD1 = d.tiffHeader + f);
            }
            return r.prototype = i.prototype, r;
        }), n("moxie/runtime/html5/image/JPEG", [ "moxie/core/utils/Basic", "moxie/core/Exceptions", "moxie/runtime/html5/image/JPEGHeaders", "moxie/runtime/html5/utils/BinaryReader", "moxie/runtime/html5/image/ExifParser" ], function(e, t, i, n, r) {
            function o(o) {
                function a(e) {
                    var t, i, n = 0;
                    for (e || (e = c); n <= e.length(); ) {
                        if (t = e.SHORT(n += 2), t >= 65472 && 65475 >= t) return n += 5, {
                            height: e.SHORT(n),
                            width: e.SHORT(n += 2)
                        };
                        i = e.SHORT(n += 2), n += i - 2;
                    }
                    return null;
                }
                function s() {
                    var e, t, i = d.thumb();
                    return i && (e = new n(i), t = a(e), e.clear(), t) ? (t.data = i, t) : null;
                }
                function u() {
                    d && l && c && (d.clear(), l.purge(), c.clear(), m = l = d = c = null);
                }
                var c, l, d, m;
                if (c = new n(o), 65496 !== c.SHORT(0)) throw new t.ImageError(t.ImageError.WRONG_FORMAT);
                l = new i(o);
                try {
                    d = new r(l.get("app1")[0]);
                } catch (h) {}
                m = a.call(this), e.extend(this, {
                    type: "image/jpeg",
                    size: c.length(),
                    width: m && m.width || 0,
                    height: m && m.height || 0,
                    setExif: function(t, i) {
                        return d ? ("object" === e.typeOf(t) ? e.each(t, function(e, t) {
                            d.setExif(t, e);
                        }) : d.setExif(t, i), l.set("app1", d.SEGMENT()), void 0) : !1;
                    },
                    writeHeaders: function() {
                        return arguments.length ? l.restore(arguments[0]) : l.restore(o);
                    },
                    stripHeaders: function(e) {
                        return l.strip(e);
                    },
                    purge: function() {
                        u.call(this);
                    }
                }), d && (this.meta = {
                    tiff: d.TIFF(),
                    exif: d.EXIF(),
                    gps: d.GPS(),
                    thumb: s()
                });
            }
            return o;
        }), n("moxie/runtime/html5/image/PNG", [ "moxie/core/Exceptions", "moxie/core/utils/Basic", "moxie/runtime/html5/utils/BinaryReader" ], function(e, t, i) {
            function n(n) {
                function r() {
                    var e, t;
                    return e = a.call(this, 8), "IHDR" == e.type ? (t = e.start, {
                        width: s.LONG(t),
                        height: s.LONG(t += 4)
                    }) : null;
                }
                function o() {
                    s && (s.clear(), n = l = u = c = s = null);
                }
                function a(e) {
                    var t, i, n, r;
                    return t = s.LONG(e), i = s.STRING(e += 4, 4), n = e += 4, r = s.LONG(e + t), {
                        length: t,
                        type: i,
                        start: n,
                        CRC: r
                    };
                }
                var s, u, c, l;
                s = new i(n), function() {
                    var t = 0, i = 0, n = [ 35152, 20039, 3338, 6666 ];
                    for (i = 0; i < n.length; i++, t += 2) if (n[i] != s.SHORT(t)) throw new e.ImageError(e.ImageError.WRONG_FORMAT);
                }(), l = r.call(this), t.extend(this, {
                    type: "image/png",
                    size: s.length(),
                    width: l.width,
                    height: l.height,
                    purge: function() {
                        o.call(this);
                    }
                }), o.call(this);
            }
            return n;
        }), n("moxie/runtime/html5/image/ImageInfo", [ "moxie/core/utils/Basic", "moxie/core/Exceptions", "moxie/runtime/html5/image/JPEG", "moxie/runtime/html5/image/PNG" ], function(e, t, i, n) {
            return function(r) {
                var o, a = [ i, n ];
                o = function() {
                    for (var e = 0; e < a.length; e++) try {
                        return new a[e](r);
                    } catch (i) {}
                    throw new t.ImageError(t.ImageError.WRONG_FORMAT);
                }(), e.extend(this, {
                    type: "",
                    size: 0,
                    width: 0,
                    height: 0,
                    setExif: function() {},
                    writeHeaders: function(e) {
                        return e;
                    },
                    stripHeaders: function(e) {
                        return e;
                    },
                    purge: function() {
                        r = null;
                    }
                }), e.extend(this, o), this.purge = function() {
                    o.purge(), o = null;
                };
            };
        }), n("moxie/runtime/html5/image/ResizerCanvas", [], function() {
            function e(i, n, r) {
                var o = i.width > i.height ? "width" : "height", a = Math.round(i[o] * n), s = !1;
                "nearest" !== r && (.5 > n || n > 2) && (n = .5 > n ? .5 : 2, s = !0);
                var u = t(i, n);
                return s ? e(u, a / u[o], r) : u;
            }
            function t(e, t) {
                var i = e.width, n = e.height, r = Math.round(i * t), o = Math.round(n * t), a = document.createElement("canvas");
                return a.width = r, a.height = o, a.getContext("2d").drawImage(e, 0, 0, i, n, 0, 0, r, o), 
                e = null, a;
            }
            return {
                scale: e
            };
        }), n("moxie/runtime/html5/image/Image", [ "moxie/runtime/html5/Runtime", "moxie/core/utils/Basic", "moxie/core/Exceptions", "moxie/core/utils/Encode", "moxie/file/Blob", "moxie/file/File", "moxie/runtime/html5/image/ImageInfo", "moxie/runtime/html5/image/ResizerCanvas", "moxie/core/utils/Mime", "moxie/core/utils/Env" ], function(e, t, i, n, r, o, a, s, u) {
            function c() {
                function e() {
                    if (!v && !g) throw new i.ImageError(i.DOMException.INVALID_STATE_ERR);
                    return v || g;
                }
                function c() {
                    var t = e();
                    return "canvas" == t.nodeName.toLowerCase() ? t : (v = document.createElement("canvas"), 
                    v.width = t.width, v.height = t.height, v.getContext("2d").drawImage(t, 0, 0), v);
                }
                function l(e) {
                    return n.atob(e.substring(e.indexOf("base64,") + 7));
                }
                function d(e, t) {
                    return "data:" + (t || "") + ";base64," + n.btoa(e);
                }
                function m(e) {
                    var t = this;
                    g = new Image(), g.onerror = function() {
                        p.call(this), t.trigger("error", i.ImageError.WRONG_FORMAT);
                    }, g.onload = function() {
                        t.trigger("load");
                    }, g.src = "data:" == e.substr(0, 5) ? e : d(e, y.type);
                }
                function h(e, t) {
                    var n, r = this;
                    return window.FileReader ? (n = new FileReader(), n.onload = function() {
                        t.call(r, this.result);
                    }, n.onerror = function() {
                        r.trigger("error", i.ImageError.WRONG_FORMAT);
                    }, n.readAsDataURL(e), void 0) : t.call(this, e.getAsDataURL());
                }
                function f(e, i) {
                    var n = Math.PI / 180, r = document.createElement("canvas"), o = r.getContext("2d"), a = e.width, s = e.height;
                    switch (t.inArray(i, [ 5, 6, 7, 8 ]) > -1 ? (r.width = s, r.height = a) : (r.width = a, 
                    r.height = s), i) {
                      case 2:
                        o.translate(a, 0), o.scale(-1, 1);
                        break;

                      case 3:
                        o.translate(a, s), o.rotate(180 * n);
                        break;

                      case 4:
                        o.translate(0, s), o.scale(1, -1);
                        break;

                      case 5:
                        o.rotate(90 * n), o.scale(1, -1);
                        break;

                      case 6:
                        o.rotate(90 * n), o.translate(0, -s);
                        break;

                      case 7:
                        o.rotate(90 * n), o.translate(a, -s), o.scale(-1, 1);
                        break;

                      case 8:
                        o.rotate(-90 * n), o.translate(-a, 0);
                    }
                    return o.drawImage(e, 0, 0, a, s), r;
                }
                function p() {
                    x && (x.purge(), x = null), w = g = v = y = null, b = !1;
                }
                var g, x, v, w, y, E = this, b = !1, _ = !0;
                t.extend(this, {
                    loadFromBlob: function(e) {
                        var t = this.getRuntime(), n = arguments.length > 1 ? arguments[1] : !0;
                        if (!t.can("access_binary")) throw new i.RuntimeError(i.RuntimeError.NOT_SUPPORTED_ERR);
                        return y = e, e.isDetached() ? (w = e.getSource(), m.call(this, w), void 0) : (h.call(this, e.getSource(), function(e) {
                            n && (w = l(e)), m.call(this, e);
                        }), void 0);
                    },
                    loadFromImage: function(e, t) {
                        this.meta = e.meta, y = new o(null, {
                            name: e.name,
                            size: e.size,
                            type: e.type
                        }), m.call(this, t ? w = e.getAsBinaryString() : e.getAsDataURL());
                    },
                    getInfo: function() {
                        var t, i = this.getRuntime();
                        return !x && w && i.can("access_image_binary") && (x = new a(w)), t = {
                            width: e().width || 0,
                            height: e().height || 0,
                            type: y.type || u.getFileMime(y.name),
                            size: w && w.length || y.size || 0,
                            name: y.name || "",
                            meta: null
                        }, _ && (t.meta = x && x.meta || this.meta || {}, !t.meta || !t.meta.thumb || t.meta.thumb.data instanceof r || (t.meta.thumb.data = new r(null, {
                            type: "image/jpeg",
                            data: t.meta.thumb.data
                        }))), t;
                    },
                    resize: function(t, i, n) {
                        var r = document.createElement("canvas");
                        if (r.width = t.width, r.height = t.height, r.getContext("2d").drawImage(e(), t.x, t.y, t.width, t.height, 0, 0, r.width, r.height), 
                        v = s.scale(r, i), _ = n.preserveHeaders, !_) {
                            var o = this.meta && this.meta.tiff && this.meta.tiff.Orientation || 1;
                            v = f(v, o);
                        }
                        this.width = v.width, this.height = v.height, b = !0, this.trigger("Resize");
                    },
                    getAsCanvas: function() {
                        return v || (v = c()), v.id = this.uid + "_canvas", v;
                    },
                    getAsBlob: function(e, t) {
                        return e !== this.type ? (b = !0, new o(null, {
                            name: y.name || "",
                            type: e,
                            data: E.getAsDataURL(e, t)
                        })) : new o(null, {
                            name: y.name || "",
                            type: e,
                            data: E.getAsBinaryString(e, t)
                        });
                    },
                    getAsDataURL: function(e) {
                        var t = arguments[1] || 90;
                        if (!b) return g.src;
                        if (c(), "image/jpeg" !== e) return v.toDataURL("image/png");
                        try {
                            return v.toDataURL("image/jpeg", t / 100);
                        } catch (i) {
                            return v.toDataURL("image/jpeg");
                        }
                    },
                    getAsBinaryString: function(e, t) {
                        if (!b) return w || (w = l(E.getAsDataURL(e, t))), w;
                        if ("image/jpeg" !== e) w = l(E.getAsDataURL(e, t)); else {
                            var i;
                            t || (t = 90), c();
                            try {
                                i = v.toDataURL("image/jpeg", t / 100);
                            } catch (n) {
                                i = v.toDataURL("image/jpeg");
                            }
                            w = l(i), x && (w = x.stripHeaders(w), _ && (x.meta && x.meta.exif && x.setExif({
                                PixelXDimension: this.width,
                                PixelYDimension: this.height
                            }), w = x.writeHeaders(w)), x.purge(), x = null);
                        }
                        return b = !1, w;
                    },
                    destroy: function() {
                        E = null, p.call(this), this.getRuntime().getShim().removeInstance(this.uid);
                    }
                });
            }
            return e.Image = c;
        }), n("moxie/runtime/flash/Runtime", [ "moxie/core/utils/Basic", "moxie/core/utils/Env", "moxie/core/utils/Dom", "moxie/core/Exceptions", "moxie/runtime/Runtime" ], function(e, t, i, n, o) {
            function a() {
                var e;
                try {
                    e = navigator.plugins["Shockwave Flash"], e = e.description;
                } catch (t) {
                    try {
                        e = new ActiveXObject("ShockwaveFlash.ShockwaveFlash").GetVariable("$version");
                    } catch (i) {
                        e = "0.0";
                    }
                }
                return e = e.match(/\d+/g), parseFloat(e[0] + "." + e[1]);
            }
            function s(e) {
                var n = i.get(e);
                n && "OBJECT" == n.nodeName && ("IE" === t.browser ? (n.style.display = "none", 
                function r() {
                    4 == n.readyState ? u(e) : setTimeout(r, 10);
                }()) : n.parentNode.removeChild(n));
            }
            function u(e) {
                var t = i.get(e);
                if (t) {
                    for (var n in t) "function" == typeof t[n] && (t[n] = null);
                    t.parentNode.removeChild(t);
                }
            }
            function c(u) {
                var c, m = this;
                u = e.extend({
                    swf_url: t.swf_url
                }, u), o.call(this, u, l, {
                    access_binary: function(e) {
                        return e && "browser" === m.mode;
                    },
                    access_image_binary: function(e) {
                        return e && "browser" === m.mode;
                    },
                    display_media: o.capTest(r("moxie/image/Image")),
                    do_cors: o.capTrue,
                    drag_and_drop: !1,
                    report_upload_progress: function() {
                        return "client" === m.mode;
                    },
                    resize_image: o.capTrue,
                    return_response_headers: !1,
                    return_response_type: function(t) {
                        return "json" === t && window.JSON ? !0 : !e.arrayDiff(t, [ "", "text", "document" ]) || "browser" === m.mode;
                    },
                    return_status_code: function(t) {
                        return "browser" === m.mode || !e.arrayDiff(t, [ 200, 404 ]);
                    },
                    select_file: o.capTrue,
                    select_multiple: o.capTrue,
                    send_binary_string: function(e) {
                        return e && "browser" === m.mode;
                    },
                    send_browser_cookies: function(e) {
                        return e && "browser" === m.mode;
                    },
                    send_custom_headers: function(e) {
                        return e && "browser" === m.mode;
                    },
                    send_multipart: o.capTrue,
                    slice_blob: function(e) {
                        return e && "browser" === m.mode;
                    },
                    stream_upload: function(e) {
                        return e && "browser" === m.mode;
                    },
                    summon_file_dialog: !1,
                    upload_filesize: function(t) {
                        return e.parseSizeStr(t) <= 2097152 || "client" === m.mode;
                    },
                    use_http_method: function(t) {
                        return !e.arrayDiff(t, [ "GET", "POST" ]);
                    }
                }, {
                    access_binary: function(e) {
                        return e ? "browser" : "client";
                    },
                    access_image_binary: function(e) {
                        return e ? "browser" : "client";
                    },
                    report_upload_progress: function(e) {
                        return e ? "browser" : "client";
                    },
                    return_response_type: function(t) {
                        return e.arrayDiff(t, [ "", "text", "json", "document" ]) ? "browser" : [ "client", "browser" ];
                    },
                    return_status_code: function(t) {
                        return e.arrayDiff(t, [ 200, 404 ]) ? "browser" : [ "client", "browser" ];
                    },
                    send_binary_string: function(e) {
                        return e ? "browser" : "client";
                    },
                    send_browser_cookies: function(e) {
                        return e ? "browser" : "client";
                    },
                    send_custom_headers: function(e) {
                        return e ? "browser" : "client";
                    },
                    slice_blob: function(e) {
                        return e ? "browser" : "client";
                    },
                    stream_upload: function(e) {
                        return e ? "client" : "browser";
                    },
                    upload_filesize: function(t) {
                        return e.parseSizeStr(t) >= 2097152 ? "client" : "browser";
                    }
                }, "client"), a() < 11.3 && (this.mode = !1), e.extend(this, {
                    getShim: function() {
                        return i.get(this.uid);
                    },
                    shimExec: function(e, t) {
                        var i = [].slice.call(arguments, 2);
                        return m.getShim().exec(this.uid, e, t, i);
                    },
                    init: function() {
                        var i, r, a;
                        a = this.getShimContainer(), e.extend(a.style, {
                            position: "absolute",
                            top: "-8px",
                            left: "-8px",
                            width: "9px",
                            height: "9px",
                            overflow: "hidden"
                        }), i = '<object id="' + this.uid + '" type="application/x-shockwave-flash" data="' + u.swf_url + '" ', 
                        "IE" === t.browser && (i += 'classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" '), 
                        i += 'width="100%" height="100%" style="outline:0"><param name="movie" value="' + u.swf_url + '" />' + '<param name="flashvars" value="uid=' + escape(this.uid) + "&target=" + o.getGlobalEventTarget() + '" />' + '<param name="wmode" value="transparent" />' + '<param name="allowscriptaccess" value="always" />' + "</object>", 
                        "IE" === t.browser ? (r = document.createElement("div"), a.appendChild(r), r.outerHTML = i, 
                        r = a = null) : a.innerHTML = i, c = setTimeout(function() {
                            m && !m.initialized && m.trigger("Error", new n.RuntimeError(n.RuntimeError.NOT_INIT_ERR));
                        }, 5e3);
                    },
                    destroy: function(e) {
                        return function() {
                            s(m.uid), e.call(m), clearTimeout(c), u = c = e = m = null;
                        };
                    }(this.destroy)
                }, d);
            }
            var l = "flash", d = {};
            return o.addConstructor(l, c), d;
        }), n("moxie/runtime/flash/file/Blob", [ "moxie/runtime/flash/Runtime", "moxie/file/Blob" ], function(e, t) {
            var i = {
                slice: function(e, i, n, r) {
                    var o = this.getRuntime();
                    return 0 > i ? i = Math.max(e.size + i, 0) : i > 0 && (i = Math.min(i, e.size)), 
                    0 > n ? n = Math.max(e.size + n, 0) : n > 0 && (n = Math.min(n, e.size)), e = o.shimExec.call(this, "Blob", "slice", i, n, r || ""), 
                    e && (e = new t(o.uid, e)), e;
                }
            };
            return e.Blob = i;
        }), n("moxie/runtime/flash/file/FileInput", [ "moxie/runtime/flash/Runtime", "moxie/file/File", "moxie/core/utils/Dom", "moxie/core/utils/Basic" ], function(e, t, i, n) {
            var r = {
                init: function(e) {
                    var r = this, o = this.getRuntime(), a = i.get(e.browse_button);
                    a && (a.setAttribute("tabindex", -1), a = null), this.bind("Change", function() {
                        var e = o.shimExec.call(r, "FileInput", "getFiles");
                        r.files = [], n.each(e, function(e) {
                            r.files.push(new t(o.uid, e));
                        });
                    }, 999), this.getRuntime().shimExec.call(this, "FileInput", "init", {
                        accept: e.accept,
                        multiple: e.multiple
                    }), this.trigger("ready");
                }
            };
            return e.FileInput = r;
        }), n("moxie/runtime/flash/file/FileReader", [ "moxie/runtime/flash/Runtime", "moxie/core/utils/Encode" ], function(e, t) {
            function i(e, i) {
                switch (i) {
                  case "readAsText":
                    return t.atob(e, "utf8");

                  case "readAsBinaryString":
                    return t.atob(e);

                  case "readAsDataURL":
                    return e;
                }
                return null;
            }
            var n = {
                read: function(e, t) {
                    var n = this;
                    return n.result = "", "readAsDataURL" === e && (n.result = "data:" + (t.type || "") + ";base64,"), 
                    n.bind("Progress", function(t, r) {
                        r && (n.result += i(r, e));
                    }, 999), n.getRuntime().shimExec.call(this, "FileReader", "readAsBase64", t.uid);
                }
            };
            return e.FileReader = n;
        }), n("moxie/runtime/flash/file/FileReaderSync", [ "moxie/runtime/flash/Runtime", "moxie/core/utils/Encode" ], function(e, t) {
            function i(e, i) {
                switch (i) {
                  case "readAsText":
                    return t.atob(e, "utf8");

                  case "readAsBinaryString":
                    return t.atob(e);

                  case "readAsDataURL":
                    return e;
                }
                return null;
            }
            var n = {
                read: function(e, t) {
                    var n, r = this.getRuntime();
                    return (n = r.shimExec.call(this, "FileReaderSync", "readAsBase64", t.uid)) ? ("readAsDataURL" === e && (n = "data:" + (t.type || "") + ";base64," + n), 
                    i(n, e, t.type)) : null;
                }
            };
            return e.FileReaderSync = n;
        }), n("moxie/runtime/flash/runtime/Transporter", [ "moxie/runtime/flash/Runtime", "moxie/file/Blob" ], function(e, t) {
            var i = {
                getAsBlob: function(e) {
                    var i = this.getRuntime(), n = i.shimExec.call(this, "Transporter", "getAsBlob", e);
                    return n ? new t(i.uid, n) : null;
                }
            };
            return e.Transporter = i;
        }), n("moxie/runtime/flash/xhr/XMLHttpRequest", [ "moxie/runtime/flash/Runtime", "moxie/core/utils/Basic", "moxie/file/Blob", "moxie/file/File", "moxie/file/FileReaderSync", "moxie/runtime/flash/file/FileReaderSync", "moxie/xhr/FormData", "moxie/runtime/Transporter", "moxie/runtime/flash/runtime/Transporter" ], function(e, t, i, n, r, o, a, s) {
            var u = {
                send: function(e, n) {
                    function r() {
                        e.transport = l.mode, l.shimExec.call(c, "XMLHttpRequest", "send", e, n);
                    }
                    function o(e, t) {
                        l.shimExec.call(c, "XMLHttpRequest", "appendBlob", e, t.uid), n = null, r();
                    }
                    function u(e, t) {
                        var i = new s();
                        i.bind("TransportingComplete", function() {
                            t(this.result);
                        }), i.transport(e.getSource(), e.type, {
                            ruid: l.uid
                        });
                    }
                    var c = this, l = c.getRuntime();
                    if (t.isEmptyObj(e.headers) || t.each(e.headers, function(e, t) {
                        l.shimExec.call(c, "XMLHttpRequest", "setRequestHeader", t, e.toString());
                    }), n instanceof a) {
                        var d;
                        if (n.each(function(e, t) {
                            e instanceof i ? d = t : l.shimExec.call(c, "XMLHttpRequest", "append", t, e);
                        }), n.hasBlob()) {
                            var m = n.getBlob();
                            m.isDetached() ? u(m, function(e) {
                                m.destroy(), o(d, e);
                            }) : o(d, m);
                        } else n = null, r();
                    } else n instanceof i ? n.isDetached() ? u(n, function(e) {
                        n.destroy(), n = e.uid, r();
                    }) : (n = n.uid, r()) : r();
                },
                getResponse: function(e) {
                    var i, o, a = this.getRuntime();
                    if (o = a.shimExec.call(this, "XMLHttpRequest", "getResponseAsBlob")) {
                        if (o = new n(a.uid, o), "blob" === e) return o;
                        try {
                            if (i = new r(), ~t.inArray(e, [ "", "text" ])) return i.readAsText(o);
                            if ("json" === e && window.JSON) return JSON.parse(i.readAsText(o));
                        } finally {
                            o.destroy();
                        }
                    }
                    return null;
                },
                abort: function() {
                    var e = this.getRuntime();
                    e.shimExec.call(this, "XMLHttpRequest", "abort"), this.dispatchEvent("readystatechange"), 
                    this.dispatchEvent("abort");
                }
            };
            return e.XMLHttpRequest = u;
        }), n("moxie/runtime/flash/image/Image", [ "moxie/runtime/flash/Runtime", "moxie/core/utils/Basic", "moxie/runtime/Transporter", "moxie/file/Blob", "moxie/file/FileReaderSync" ], function(e, t, i, n, r) {
            var o = {
                loadFromBlob: function(e) {
                    function t(e) {
                        r.shimExec.call(n, "Image", "loadFromBlob", e.uid), n = r = null;
                    }
                    var n = this, r = n.getRuntime();
                    if (e.isDetached()) {
                        var o = new i();
                        o.bind("TransportingComplete", function() {
                            t(o.result.getSource());
                        }), o.transport(e.getSource(), e.type, {
                            ruid: r.uid
                        });
                    } else t(e.getSource());
                },
                loadFromImage: function(e) {
                    var t = this.getRuntime();
                    return t.shimExec.call(this, "Image", "loadFromImage", e.uid);
                },
                getInfo: function() {
                    var e = this.getRuntime(), t = e.shimExec.call(this, "Image", "getInfo");
                    return t.meta && t.meta.thumb && t.meta.thumb.data && !(e.meta.thumb.data instanceof n) && (t.meta.thumb.data = new n(e.uid, t.meta.thumb.data)), 
                    t;
                },
                getAsBlob: function(e, t) {
                    var i = this.getRuntime(), r = i.shimExec.call(this, "Image", "getAsBlob", e, t);
                    return r ? new n(i.uid, r) : null;
                },
                getAsDataURL: function() {
                    var e, t = this.getRuntime(), i = t.Image.getAsBlob.apply(this, arguments);
                    return i ? (e = new r(), e.readAsDataURL(i)) : null;
                }
            };
            return e.Image = o;
        }), n("moxie/runtime/silverlight/Runtime", [ "moxie/core/utils/Basic", "moxie/core/utils/Env", "moxie/core/utils/Dom", "moxie/core/Exceptions", "moxie/runtime/Runtime" ], function(e, t, i, n, o) {
            function a(e) {
                var t, i, n, r, o, a = !1, s = null, u = 0;
                try {
                    try {
                        s = new ActiveXObject("AgControl.AgControl"), s.IsVersionSupported(e) && (a = !0), 
                        s = null;
                    } catch (c) {
                        var l = navigator.plugins["Silverlight Plug-In"];
                        if (l) {
                            for (t = l.description, "1.0.30226.2" === t && (t = "2.0.30226.2"), i = t.split("."); i.length > 3; ) i.pop();
                            for (;i.length < 4; ) i.push(0);
                            for (n = e.split("."); n.length > 4; ) n.pop();
                            do {
                                r = parseInt(n[u], 10), o = parseInt(i[u], 10), u++;
                            } while (u < n.length && r === o);
                            o >= r && !isNaN(r) && (a = !0);
                        }
                    }
                } catch (d) {
                    a = !1;
                }
                return a;
            }
            function s(s) {
                var l, d = this;
                s = e.extend({
                    xap_url: t.xap_url
                }, s), o.call(this, s, u, {
                    access_binary: o.capTrue,
                    access_image_binary: o.capTrue,
                    display_media: o.capTest(r("moxie/image/Image")),
                    do_cors: o.capTrue,
                    drag_and_drop: !1,
                    report_upload_progress: o.capTrue,
                    resize_image: o.capTrue,
                    return_response_headers: function(e) {
                        return e && "client" === d.mode;
                    },
                    return_response_type: function(e) {
                        return "json" !== e ? !0 : !!window.JSON;
                    },
                    return_status_code: function(t) {
                        return "client" === d.mode || !e.arrayDiff(t, [ 200, 404 ]);
                    },
                    select_file: o.capTrue,
                    select_multiple: o.capTrue,
                    send_binary_string: o.capTrue,
                    send_browser_cookies: function(e) {
                        return e && "browser" === d.mode;
                    },
                    send_custom_headers: function(e) {
                        return e && "client" === d.mode;
                    },
                    send_multipart: o.capTrue,
                    slice_blob: o.capTrue,
                    stream_upload: !0,
                    summon_file_dialog: !1,
                    upload_filesize: o.capTrue,
                    use_http_method: function(t) {
                        return "client" === d.mode || !e.arrayDiff(t, [ "GET", "POST" ]);
                    }
                }, {
                    return_response_headers: function(e) {
                        return e ? "client" : "browser";
                    },
                    return_status_code: function(t) {
                        return e.arrayDiff(t, [ 200, 404 ]) ? "client" : [ "client", "browser" ];
                    },
                    send_browser_cookies: function(e) {
                        return e ? "browser" : "client";
                    },
                    send_custom_headers: function(e) {
                        return e ? "client" : "browser";
                    },
                    use_http_method: function(t) {
                        return e.arrayDiff(t, [ "GET", "POST" ]) ? "client" : [ "client", "browser" ];
                    }
                }), a("2.0.31005.0") && "Opera" !== t.browser || (this.mode = !1), e.extend(this, {
                    getShim: function() {
                        return i.get(this.uid).content.Moxie;
                    },
                    shimExec: function(e, t) {
                        var i = [].slice.call(arguments, 2);
                        return d.getShim().exec(this.uid, e, t, i);
                    },
                    init: function() {
                        var e;
                        e = this.getShimContainer(), e.innerHTML = '<object id="' + this.uid + '" data="data:application/x-silverlight," type="application/x-silverlight-2" width="100%" height="100%" style="outline:none;">' + '<param name="source" value="' + s.xap_url + '"/>' + '<param name="background" value="Transparent"/>' + '<param name="windowless" value="true"/>' + '<param name="enablehtmlaccess" value="true"/>' + '<param name="initParams" value="uid=' + this.uid + ",target=" + o.getGlobalEventTarget() + '"/>' + "</object>", 
                        l = setTimeout(function() {
                            d && !d.initialized && d.trigger("Error", new n.RuntimeError(n.RuntimeError.NOT_INIT_ERR));
                        }, "Windows" !== t.OS ? 1e4 : 5e3);
                    },
                    destroy: function(e) {
                        return function() {
                            e.call(d), clearTimeout(l), s = l = e = d = null;
                        };
                    }(this.destroy)
                }, c);
            }
            var u = "silverlight", c = {};
            return o.addConstructor(u, s), c;
        }), n("moxie/runtime/silverlight/file/Blob", [ "moxie/runtime/silverlight/Runtime", "moxie/core/utils/Basic", "moxie/runtime/flash/file/Blob" ], function(e, t, i) {
            return e.Blob = t.extend({}, i);
        }), n("moxie/runtime/silverlight/file/FileInput", [ "moxie/runtime/silverlight/Runtime", "moxie/file/File", "moxie/core/utils/Dom", "moxie/core/utils/Basic" ], function(e, t, i, n) {
            function r(e) {
                for (var t = "", i = 0; i < e.length; i++) t += ("" !== t ? "|" : "") + e[i].title + " | *." + e[i].extensions.replace(/,/g, ";*.");
                return t;
            }
            var o = {
                init: function(e) {
                    var o = this, a = this.getRuntime(), s = i.get(e.browse_button);
                    s && (s.setAttribute("tabindex", -1), s = null), this.bind("Change", function() {
                        var e = a.shimExec.call(o, "FileInput", "getFiles");
                        o.files = [], n.each(e, function(e) {
                            o.files.push(new t(a.uid, e));
                        });
                    }, 999), a.shimExec.call(this, "FileInput", "init", r(e.accept), e.multiple), this.trigger("ready");
                },
                setOption: function(e, t) {
                    "accept" == e && (t = r(t)), this.getRuntime().shimExec.call(this, "FileInput", "setOption", e, t);
                }
            };
            return e.FileInput = o;
        }), n("moxie/runtime/silverlight/file/FileDrop", [ "moxie/runtime/silverlight/Runtime", "moxie/core/utils/Dom", "moxie/core/utils/Events" ], function(e, t, i) {
            var n = {
                init: function() {
                    var e, n = this, r = n.getRuntime();
                    return e = r.getShimContainer(), i.addEvent(e, "dragover", function(e) {
                        e.preventDefault(), e.stopPropagation(), e.dataTransfer.dropEffect = "copy";
                    }, n.uid), i.addEvent(e, "dragenter", function(e) {
                        e.preventDefault();
                        var i = t.get(r.uid).dragEnter(e);
                        i && e.stopPropagation();
                    }, n.uid), i.addEvent(e, "drop", function(e) {
                        e.preventDefault();
                        var i = t.get(r.uid).dragDrop(e);
                        i && e.stopPropagation();
                    }, n.uid), r.shimExec.call(this, "FileDrop", "init");
                }
            };
            return e.FileDrop = n;
        }), n("moxie/runtime/silverlight/file/FileReader", [ "moxie/runtime/silverlight/Runtime", "moxie/core/utils/Basic", "moxie/runtime/flash/file/FileReader" ], function(e, t, i) {
            return e.FileReader = t.extend({}, i);
        }), n("moxie/runtime/silverlight/file/FileReaderSync", [ "moxie/runtime/silverlight/Runtime", "moxie/core/utils/Basic", "moxie/runtime/flash/file/FileReaderSync" ], function(e, t, i) {
            return e.FileReaderSync = t.extend({}, i);
        }), n("moxie/runtime/silverlight/runtime/Transporter", [ "moxie/runtime/silverlight/Runtime", "moxie/core/utils/Basic", "moxie/runtime/flash/runtime/Transporter" ], function(e, t, i) {
            return e.Transporter = t.extend({}, i);
        }), n("moxie/runtime/silverlight/xhr/XMLHttpRequest", [ "moxie/runtime/silverlight/Runtime", "moxie/core/utils/Basic", "moxie/runtime/flash/xhr/XMLHttpRequest", "moxie/runtime/silverlight/file/FileReaderSync", "moxie/runtime/silverlight/runtime/Transporter" ], function(e, t, i) {
            return e.XMLHttpRequest = t.extend({}, i);
        }), n("moxie/runtime/silverlight/image/Image", [ "moxie/runtime/silverlight/Runtime", "moxie/core/utils/Basic", "moxie/file/Blob", "moxie/runtime/flash/image/Image" ], function(e, t, i, n) {
            return e.Image = t.extend({}, n, {
                getInfo: function() {
                    var e = this.getRuntime(), n = [ "tiff", "exif", "gps", "thumb" ], r = {
                        meta: {}
                    }, o = e.shimExec.call(this, "Image", "getInfo");
                    return o.meta && (t.each(n, function(e) {
                        var t, i, n, a, s = o.meta[e];
                        if (s && s.keys) for (r.meta[e] = {}, i = 0, n = s.keys.length; n > i; i++) t = s.keys[i], 
                        a = s[t], a && (/^(\d|[1-9]\d+)$/.test(a) ? a = parseInt(a, 10) : /^\d*\.\d+$/.test(a) && (a = parseFloat(a)), 
                        r.meta[e][t] = a);
                    }), r.meta && r.meta.thumb && r.meta.thumb.data && !(e.meta.thumb.data instanceof i) && (r.meta.thumb.data = new i(e.uid, r.meta.thumb.data))), 
                    r.width = parseInt(o.width, 10), r.height = parseInt(o.height, 10), r.size = parseInt(o.size, 10), 
                    r.type = o.type, r.name = o.name, r;
                },
                resize: function(e, t, i) {
                    this.getRuntime().shimExec.call(this, "Image", "resize", e.x, e.y, e.width, e.height, t, i.preserveHeaders, i.resample);
                }
            });
        }), n("moxie/runtime/html4/Runtime", [ "moxie/core/utils/Basic", "moxie/core/Exceptions", "moxie/runtime/Runtime", "moxie/core/utils/Env" ], function(e, t, i, n) {
            function o(t) {
                var o = this, u = i.capTest, c = i.capTrue;
                i.call(this, t, a, {
                    access_binary: u(window.FileReader || window.File && File.getAsDataURL),
                    access_image_binary: !1,
                    display_media: u((n.can("create_canvas") || n.can("use_data_uri_over32kb")) && r("moxie/image/Image")),
                    do_cors: !1,
                    drag_and_drop: !1,
                    filter_by_extension: u(function() {
                        return !("Chrome" === n.browser && n.verComp(n.version, 28, "<") || "IE" === n.browser && n.verComp(n.version, 10, "<") || "Safari" === n.browser && n.verComp(n.version, 7, "<") || "Firefox" === n.browser && n.verComp(n.version, 37, "<"));
                    }()),
                    resize_image: function() {
                        return s.Image && o.can("access_binary") && n.can("create_canvas");
                    },
                    report_upload_progress: !1,
                    return_response_headers: !1,
                    return_response_type: function(t) {
                        return "json" === t && window.JSON ? !0 : !!~e.inArray(t, [ "text", "document", "" ]);
                    },
                    return_status_code: function(t) {
                        return !e.arrayDiff(t, [ 200, 404 ]);
                    },
                    select_file: function() {
                        return n.can("use_fileinput");
                    },
                    select_multiple: !1,
                    send_binary_string: !1,
                    send_custom_headers: !1,
                    send_multipart: !0,
                    slice_blob: !1,
                    stream_upload: function() {
                        return o.can("select_file");
                    },
                    summon_file_dialog: function() {
                        return o.can("select_file") && !("Firefox" === n.browser && n.verComp(n.version, 4, "<") || "Opera" === n.browser && n.verComp(n.version, 12, "<") || "IE" === n.browser && n.verComp(n.version, 10, "<"));
                    },
                    upload_filesize: c,
                    use_http_method: function(t) {
                        return !e.arrayDiff(t, [ "GET", "POST" ]);
                    }
                }), e.extend(this, {
                    init: function() {
                        this.trigger("Init");
                    },
                    destroy: function(e) {
                        return function() {
                            e.call(o), e = o = null;
                        };
                    }(this.destroy)
                }), e.extend(this.getShim(), s);
            }
            var a = "html4", s = {};
            return i.addConstructor(a, o), s;
        }), n("moxie/runtime/html4/file/FileInput", [ "moxie/runtime/html4/Runtime", "moxie/file/File", "moxie/core/utils/Basic", "moxie/core/utils/Dom", "moxie/core/utils/Events", "moxie/core/utils/Mime", "moxie/core/utils/Env" ], function(e, t, i, n, r, o, a) {
            function s() {
                function e() {
                    var o, c, d, m, h, f, p = this, g = p.getRuntime();
                    f = i.guid("uid_"), o = g.getShimContainer(), s && (d = n.get(s + "_form"), d && (i.extend(d.style, {
                        top: "100%"
                    }), d.firstChild.setAttribute("tabindex", -1))), m = document.createElement("form"), 
                    m.setAttribute("id", f + "_form"), m.setAttribute("method", "post"), m.setAttribute("enctype", "multipart/form-data"), 
                    m.setAttribute("encoding", "multipart/form-data"), i.extend(m.style, {
                        overflow: "hidden",
                        position: "absolute",
                        top: 0,
                        left: 0,
                        width: "100%",
                        height: "100%"
                    }), h = document.createElement("input"), h.setAttribute("id", f), h.setAttribute("type", "file"), 
                    h.setAttribute("accept", l.join(",")), g.can("summon_file_dialog") && h.setAttribute("tabindex", -1), 
                    i.extend(h.style, {
                        fontSize: "999px",
                        opacity: 0
                    }), m.appendChild(h), o.appendChild(m), i.extend(h.style, {
                        position: "absolute",
                        top: 0,
                        left: 0,
                        width: "100%",
                        height: "100%"
                    }), "IE" === a.browser && a.verComp(a.version, 10, "<") && i.extend(h.style, {
                        filter: "progid:DXImageTransform.Microsoft.Alpha(opacity=0)"
                    }), h.onchange = function() {
                        var i;
                        this.value && (i = this.files ? this.files[0] : {
                            name: this.value
                        }, i = new t(g.uid, i), this.onchange = function() {}, e.call(p), p.files = [ i ], 
                        h.setAttribute("id", i.uid), m.setAttribute("id", i.uid + "_form"), p.trigger("change"), 
                        h = m = null);
                    }, g.can("summon_file_dialog") && (c = n.get(u.browse_button), r.removeEvent(c, "click", p.uid), 
                    r.addEvent(c, "click", function(e) {
                        h && !h.disabled && h.click(), e.preventDefault();
                    }, p.uid)), s = f, o = d = c = null;
                }
                var s, u, c, l = [];
                i.extend(this, {
                    init: function(t) {
                        var i, a = this, s = a.getRuntime();
                        u = t, l = o.extList2mimes(t.accept, s.can("filter_by_extension")), i = s.getShimContainer(), 
                        function() {
                            var e, o, l;
                            e = n.get(t.browse_button), c = n.getStyle(e, "z-index") || "auto", s.can("summon_file_dialog") ? ("static" === n.getStyle(e, "position") && (e.style.position = "relative"), 
                            a.bind("Refresh", function() {
                                o = parseInt(c, 10) || 1, n.get(u.browse_button).style.zIndex = o, this.getRuntime().getShimContainer().style.zIndex = o - 1;
                            })) : e.setAttribute("tabindex", -1), l = s.can("summon_file_dialog") ? e : i, r.addEvent(l, "mouseover", function() {
                                a.trigger("mouseenter");
                            }, a.uid), r.addEvent(l, "mouseout", function() {
                                a.trigger("mouseleave");
                            }, a.uid), r.addEvent(l, "mousedown", function() {
                                a.trigger("mousedown");
                            }, a.uid), r.addEvent(n.get(t.container), "mouseup", function() {
                                a.trigger("mouseup");
                            }, a.uid), e = null;
                        }(), e.call(this), i = null, a.trigger({
                            type: "ready",
                            async: !0
                        });
                    },
                    setOption: function(e, t) {
                        var i, r = this.getRuntime();
                        "accept" == e && (l = t.mimes || o.extList2mimes(t, r.can("filter_by_extension"))), 
                        i = n.get(s), i && i.setAttribute("accept", l.join(","));
                    },
                    disable: function(e) {
                        var t;
                        (t = n.get(s)) && (t.disabled = !!e);
                    },
                    destroy: function() {
                        var e = this.getRuntime(), t = e.getShim(), i = e.getShimContainer(), o = u && n.get(u.container), a = u && n.get(u.browse_button);
                        o && r.removeAllEvents(o, this.uid), a && (r.removeAllEvents(a, this.uid), a.style.zIndex = c), 
                        i && (r.removeAllEvents(i, this.uid), i.innerHTML = ""), t.removeInstance(this.uid), 
                        s = l = u = i = o = a = t = null;
                    }
                });
            }
            return e.FileInput = s;
        }), n("moxie/runtime/html4/file/FileReader", [ "moxie/runtime/html4/Runtime", "moxie/runtime/html5/file/FileReader" ], function(e, t) {
            return e.FileReader = t;
        }), n("moxie/runtime/html4/xhr/XMLHttpRequest", [ "moxie/runtime/html4/Runtime", "moxie/core/utils/Basic", "moxie/core/utils/Dom", "moxie/core/utils/Url", "moxie/core/Exceptions", "moxie/core/utils/Events", "moxie/file/Blob", "moxie/xhr/FormData" ], function(e, t, i, n, r, o, a, s) {
            function u() {
                function e(e) {
                    var t, n, r, a, s = this, u = !1;
                    if (l) {
                        if (t = l.id.replace(/_iframe$/, ""), n = i.get(t + "_form")) {
                            for (r = n.getElementsByTagName("input"), a = r.length; a--; ) switch (r[a].getAttribute("type")) {
                              case "hidden":
                                r[a].parentNode.removeChild(r[a]);
                                break;

                              case "file":
                                u = !0;
                            }
                            r = [], u || n.parentNode.removeChild(n), n = null;
                        }
                        setTimeout(function() {
                            o.removeEvent(l, "load", s.uid), l.parentNode && l.parentNode.removeChild(l);
                            var t = s.getRuntime().getShimContainer();
                            t.children.length || t.parentNode.removeChild(t), t = l = null, e();
                        }, 1);
                    }
                }
                var u, c, l;
                t.extend(this, {
                    send: function(d, m) {
                        function h() {
                            var i = w.getShimContainer() || document.body, r = document.createElement("div");
                            r.innerHTML = '<iframe id="' + f + '_iframe" name="' + f + '_iframe" src="javascript:&quot;&quot;" style="display:none"></iframe>', 
                            l = r.firstChild, i.appendChild(l), o.addEvent(l, "load", function() {
                                var i;
                                try {
                                    i = l.contentWindow.document || l.contentDocument || window.frames[l.id].document, 
                                    /^4(0[0-9]|1[0-7]|2[2346])\s/.test(i.title) ? u = i.title.replace(/^(\d+).*$/, "$1") : (u = 200, 
                                    c = t.trim(i.body.innerHTML), v.trigger({
                                        type: "progress",
                                        loaded: c.length,
                                        total: c.length
                                    }), x && v.trigger({
                                        type: "uploadprogress",
                                        loaded: x.size || 1025,
                                        total: x.size || 1025
                                    }));
                                } catch (r) {
                                    if (!n.hasSameOrigin(d.url)) return e.call(v, function() {
                                        v.trigger("error");
                                    }), void 0;
                                    u = 404;
                                }
                                e.call(v, function() {
                                    v.trigger("load");
                                });
                            }, v.uid);
                        }
                        var f, p, g, x, v = this, w = v.getRuntime();
                        if (u = c = null, m instanceof s && m.hasBlob()) {
                            if (x = m.getBlob(), f = x.uid, g = i.get(f), p = i.get(f + "_form"), !p) throw new r.DOMException(r.DOMException.NOT_FOUND_ERR);
                        } else f = t.guid("uid_"), p = document.createElement("form"), p.setAttribute("id", f + "_form"), 
                        p.setAttribute("method", d.method), p.setAttribute("enctype", "multipart/form-data"), 
                        p.setAttribute("encoding", "multipart/form-data"), w.getShimContainer().appendChild(p);
                        p.setAttribute("target", f + "_iframe"), m instanceof s && m.each(function(e, i) {
                            if (e instanceof a) g && g.setAttribute("name", i); else {
                                var n = document.createElement("input");
                                t.extend(n, {
                                    type: "hidden",
                                    name: i,
                                    value: e
                                }), g ? p.insertBefore(n, g) : p.appendChild(n);
                            }
                        }), p.setAttribute("action", d.url), h(), p.submit(), v.trigger("loadstart");
                    },
                    getStatus: function() {
                        return u;
                    },
                    getResponse: function(e) {
                        if ("json" === e && "string" === t.typeOf(c) && window.JSON) try {
                            return JSON.parse(c.replace(/^\s*<pre[^>]*>/, "").replace(/<\/pre>\s*$/, ""));
                        } catch (i) {
                            return null;
                        }
                        return c;
                    },
                    abort: function() {
                        var t = this;
                        l && l.contentWindow && (l.contentWindow.stop ? l.contentWindow.stop() : l.contentWindow.document.execCommand ? l.contentWindow.document.execCommand("Stop") : l.src = "about:blank"), 
                        e.call(this, function() {
                            t.dispatchEvent("abort");
                        });
                    },
                    destroy: function() {
                        this.getRuntime().getShim().removeInstance(this.uid);
                    }
                });
            }
            return e.XMLHttpRequest = u;
        }), n("moxie/runtime/html4/image/Image", [ "moxie/runtime/html4/Runtime", "moxie/runtime/html5/image/Image" ], function(e, t) {
            return e.Image = t;
        }), a([ "moxie/core/utils/Basic", "moxie/core/utils/Encode", "moxie/core/utils/Env", "moxie/core/Exceptions", "moxie/core/utils/Dom", "moxie/core/EventTarget", "moxie/runtime/Runtime", "moxie/runtime/RuntimeClient", "moxie/file/Blob", "moxie/core/I18n", "moxie/core/utils/Mime", "moxie/file/FileInput", "moxie/file/File", "moxie/file/FileDrop", "moxie/file/FileReader", "moxie/core/utils/Url", "moxie/runtime/RuntimeTarget", "moxie/xhr/FormData", "moxie/xhr/XMLHttpRequest", "moxie/image/Image", "moxie/core/utils/Events", "moxie/runtime/html5/image/ResizerCanvas" ]);
    }(this);
});

!function(e, t) {
    var i = function() {
        var e = {};
        return t.apply(e, arguments), e.plupload;
    };
    "function" == typeof define && define.amd ? define("plupload", [ "./moxie" ], i) : "object" == typeof module && module.exports ? module.exports = i(require("./moxie")) : e.plupload = i(e.moxie);
}(this || window, function(e) {
    !function(e, t, i) {
        function n(e) {
            function t(e, t, i) {
                var r = {
                    chunks: "slice_blob",
                    jpgresize: "send_binary_string",
                    pngresize: "send_binary_string",
                    progress: "report_upload_progress",
                    multi_selection: "select_multiple",
                    dragdrop: "drag_and_drop",
                    drop_element: "drag_and_drop",
                    headers: "send_custom_headers",
                    urlstream_upload: "send_binary_string",
                    canSendBinary: "send_binary",
                    triggerDialog: "summon_file_dialog"
                };
                r[e] ? n[r[e]] = t : i || (n[e] = t);
            }
            var i = e.required_features, n = {};
            return "string" == typeof i ? l.each(i.split(/\s*,\s*/), function(e) {
                t(e, !0);
            }) : "object" == typeof i ? l.each(i, function(e, i) {
                t(i, e);
            }) : i === !0 && (e.chunk_size && e.chunk_size > 0 && (n.slice_blob = !0), l.isEmptyObj(e.resize) && e.multipart !== !1 || (n.send_binary_string = !0), 
            e.http_method && (n.use_http_method = e.http_method), l.each(e, function(e, i) {
                t(i, !!e, !0);
            })), n;
        }
        var r = window.setTimeout, s = {}, a = t.core.utils, o = t.runtime.Runtime, l = {
            VERSION: "2.3.6",
            STOPPED: 1,
            STARTED: 2,
            QUEUED: 1,
            UPLOADING: 2,
            FAILED: 4,
            DONE: 5,
            GENERIC_ERROR: -100,
            HTTP_ERROR: -200,
            IO_ERROR: -300,
            SECURITY_ERROR: -400,
            INIT_ERROR: -500,
            FILE_SIZE_ERROR: -600,
            FILE_EXTENSION_ERROR: -601,
            FILE_DUPLICATE_ERROR: -602,
            IMAGE_FORMAT_ERROR: -700,
            MEMORY_ERROR: -701,
            IMAGE_DIMENSIONS_ERROR: -702,
            moxie: t,
            mimeTypes: a.Mime.mimes,
            ua: a.Env,
            typeOf: a.Basic.typeOf,
            extend: a.Basic.extend,
            guid: a.Basic.guid,
            getAll: function(e) {
                var t, i = [];
                "array" !== l.typeOf(e) && (e = [ e ]);
                for (var n = e.length; n--; ) t = l.get(e[n]), t && i.push(t);
                return i.length ? i : null;
            },
            get: a.Dom.get,
            each: a.Basic.each,
            getPos: a.Dom.getPos,
            getSize: a.Dom.getSize,
            xmlEncode: function(e) {
                var t = {
                    "<": "lt",
                    ">": "gt",
                    "&": "amp",
                    '"': "quot",
                    "'": "#39"
                }, i = /[<>&\"\']/g;
                return e ? ("" + e).replace(i, function(e) {
                    return t[e] ? "&" + t[e] + ";" : e;
                }) : e;
            },
            toArray: a.Basic.toArray,
            inArray: a.Basic.inArray,
            inSeries: a.Basic.inSeries,
            addI18n: t.core.I18n.addI18n,
            translate: t.core.I18n.translate,
            sprintf: a.Basic.sprintf,
            isEmptyObj: a.Basic.isEmptyObj,
            hasClass: a.Dom.hasClass,
            addClass: a.Dom.addClass,
            removeClass: a.Dom.removeClass,
            getStyle: a.Dom.getStyle,
            addEvent: a.Events.addEvent,
            removeEvent: a.Events.removeEvent,
            removeAllEvents: a.Events.removeAllEvents,
            cleanName: function(e) {
                var t, i;
                for (i = [ /[\300-\306]/g, "A", /[\340-\346]/g, "a", /\307/g, "C", /\347/g, "c", /[\310-\313]/g, "E", /[\350-\353]/g, "e", /[\314-\317]/g, "I", /[\354-\357]/g, "i", /\321/g, "N", /\361/g, "n", /[\322-\330]/g, "O", /[\362-\370]/g, "o", /[\331-\334]/g, "U", /[\371-\374]/g, "u" ], 
                t = 0; t < i.length; t += 2) e = e.replace(i[t], i[t + 1]);
                return e = e.replace(/\s+/g, "_"), e = e.replace(/[^a-z0-9_\-\.]+/gi, "");
            },
            buildUrl: function(e, t) {
                var i = "";
                return l.each(t, function(e, t) {
                    i += (i ? "&" : "") + encodeURIComponent(t) + "=" + encodeURIComponent(e);
                }), i && (e += (e.indexOf("?") > 0 ? "&" : "?") + i), e;
            },
            formatSize: function(e) {
                function t(e, t) {
                    return Math.round(e * Math.pow(10, t)) / Math.pow(10, t);
                }
                if (e === i || /\D/.test(e)) return l.translate("N/A");
                var n = Math.pow(1024, 4);
                return e > n ? t(e / n, 1) + " " + l.translate("tb") : e > (n /= 1024) ? t(e / n, 1) + " " + l.translate("gb") : e > (n /= 1024) ? t(e / n, 1) + " " + l.translate("mb") : e > 1024 ? Math.round(e / 1024) + " " + l.translate("kb") : e + " " + l.translate("b");
            },
            parseSize: a.Basic.parseSizeStr,
            predictRuntime: function(e, t) {
                var i, n;
                return i = new l.Uploader(e), n = o.thatCan(i.getOption().required_features, t || e.runtimes), 
                i.destroy(), n;
            },
            addFileFilter: function(e, t) {
                s[e] = t;
            }
        };
        l.addFileFilter("mime_types", function(e, t, i) {
            e.length && !e.regexp.test(t.name) ? (this.trigger("Error", {
                code: l.FILE_EXTENSION_ERROR,
                message: l.translate("File extension error."),
                file: t
            }), i(!1)) : i(!0);
        }), l.addFileFilter("max_file_size", function(e, t, i) {
            var n;
            e = l.parseSize(e), t.size !== n && e && t.size > e ? (this.trigger("Error", {
                code: l.FILE_SIZE_ERROR,
                message: l.translate("File size error."),
                file: t
            }), i(!1)) : i(!0);
        }), l.addFileFilter("prevent_duplicates", function(e, t, i) {
            if (e) for (var n = this.files.length; n--; ) if (t.name === this.files[n].name && t.size === this.files[n].size) return this.trigger("Error", {
                code: l.FILE_DUPLICATE_ERROR,
                message: l.translate("Duplicate file error."),
                file: t
            }), i(!1), void 0;
            i(!0);
        }), l.addFileFilter("prevent_empty", function(e, t, n) {
            e && !t.size && t.size !== i ? (this.trigger("Error", {
                code: l.FILE_SIZE_ERROR,
                message: l.translate("File size error."),
                file: t
            }), n(!1)) : n(!0);
        }), l.Uploader = function(e) {
            function a() {
                var e, t, i = 0;
                if (this.state == l.STARTED) {
                    for (t = 0; t < D.length; t++) e || D[t].status != l.QUEUED ? i++ : (e = D[t], this.trigger("BeforeUpload", e) && (e.status = l.UPLOADING, 
                    this.trigger("UploadFile", e)));
                    i == D.length && (this.state !== l.STOPPED && (this.state = l.STOPPED, this.trigger("StateChanged")), 
                    this.trigger("UploadComplete", D));
                }
            }
            function u(e) {
                e.percent = e.size > 0 ? Math.ceil(100 * (e.loaded / e.size)) : 100, d();
            }
            function d() {
                var e, t, n, r = 0;
                for (I.reset(), e = 0; e < D.length; e++) t = D[e], t.size !== i ? (I.size += t.origSize, 
                n = t.loaded * t.origSize / t.size, (!t.completeTimestamp || t.completeTimestamp > S) && (r += n), 
                I.loaded += n) : I.size = i, t.status == l.DONE ? I.uploaded++ : t.status == l.FAILED ? I.failed++ : I.queued++;
                I.size === i ? I.percent = D.length > 0 ? Math.ceil(100 * (I.uploaded / D.length)) : 0 : (I.bytesPerSec = Math.ceil(r / ((+new Date() - S || 1) / 1e3)), 
                I.percent = I.size > 0 ? Math.ceil(100 * (I.loaded / I.size)) : 0);
            }
            function c() {
                var e = F[0] || P[0];
                return e ? e.getRuntime().uid : !1;
            }
            function f() {
                this.bind("FilesAdded FilesRemoved", function(e) {
                    e.trigger("QueueChanged"), e.refresh();
                }), this.bind("CancelUpload", b), this.bind("BeforeUpload", m), this.bind("UploadFile", _), 
                this.bind("UploadProgress", E), this.bind("StateChanged", v), this.bind("QueueChanged", d), 
                this.bind("Error", R), this.bind("FileUploaded", y), this.bind("Destroy", z);
            }
            function p(e, i) {
                var n = this, r = 0, s = [], a = {
                    runtime_order: e.runtimes,
                    required_caps: e.required_features,
                    preferred_caps: x,
                    swf_url: e.flash_swf_url,
                    xap_url: e.silverlight_xap_url
                };
                l.each(e.runtimes.split(/\s*,\s*/), function(t) {
                    e[t] && (a[t] = e[t]);
                }), e.browse_button && l.each(e.browse_button, function(i) {
                    s.push(function(s) {
                        var u = new t.file.FileInput(l.extend({}, a, {
                            accept: e.filters.mime_types,
                            name: e.file_data_name,
                            multiple: e.multi_selection,
                            container: e.container,
                            browse_button: i
                        }));
                        u.onready = function() {
                            var e = o.getInfo(this.ruid);
                            l.extend(n.features, {
                                chunks: e.can("slice_blob"),
                                multipart: e.can("send_multipart"),
                                multi_selection: e.can("select_multiple")
                            }), r++, F.push(this), s();
                        }, u.onchange = function() {
                            n.addFile(this.files);
                        }, u.bind("mouseenter mouseleave mousedown mouseup", function(t) {
                            U || (e.browse_button_hover && ("mouseenter" === t.type ? l.addClass(i, e.browse_button_hover) : "mouseleave" === t.type && l.removeClass(i, e.browse_button_hover)), 
                            e.browse_button_active && ("mousedown" === t.type ? l.addClass(i, e.browse_button_active) : "mouseup" === t.type && l.removeClass(i, e.browse_button_active)));
                        }), u.bind("mousedown", function() {
                            n.trigger("Browse");
                        }), u.bind("error runtimeerror", function() {
                            u = null, s();
                        }), u.init();
                    });
                }), e.drop_element && l.each(e.drop_element, function(e) {
                    s.push(function(i) {
                        var s = new t.file.FileDrop(l.extend({}, a, {
                            drop_zone: e
                        }));
                        s.onready = function() {
                            var e = o.getInfo(this.ruid);
                            l.extend(n.features, {
                                chunks: e.can("slice_blob"),
                                multipart: e.can("send_multipart"),
                                dragdrop: e.can("drag_and_drop")
                            }), r++, P.push(this), i();
                        }, s.ondrop = function() {
                            n.addFile(this.files);
                        }, s.bind("error runtimeerror", function() {
                            s = null, i();
                        }), s.init();
                    });
                }), l.inSeries(s, function() {
                    "function" == typeof i && i(r);
                });
            }
            function g(e, n, r, s) {
                var a = new t.image.Image();
                try {
                    a.onload = function() {
                        n.width > this.width && n.height > this.height && n.quality === i && n.preserve_headers && !n.crop ? (this.destroy(), 
                        s(e)) : a.downsize(n.width, n.height, n.crop, n.preserve_headers);
                    }, a.onresize = function() {
                        var t = this.getAsBlob(e.type, n.quality);
                        this.destroy(), s(t);
                    }, a.bind("error runtimeerror", function() {
                        this.destroy(), s(e);
                    }), a.load(e, r);
                } catch (o) {
                    s(e);
                }
            }
            function h(e, i, r) {
                function s(e, i, n) {
                    var r = O[e];
                    switch (e) {
                      case "max_file_size":
                        "max_file_size" === e && (O.max_file_size = O.filters.max_file_size = i);
                        break;

                      case "chunk_size":
                        (i = l.parseSize(i)) && (O[e] = i, O.send_file_name = !0);
                        break;

                      case "multipart":
                        O[e] = i, i || (O.send_file_name = !0);
                        break;

                      case "http_method":
                        O[e] = "PUT" === i.toUpperCase() ? "PUT" : "POST";
                        break;

                      case "unique_names":
                        O[e] = i, i && (O.send_file_name = !0);
                        break;

                      case "filters":
                        "array" === l.typeOf(i) && (i = {
                            mime_types: i
                        }), n ? l.extend(O.filters, i) : O.filters = i, i.mime_types && ("string" === l.typeOf(i.mime_types) && (i.mime_types = t.core.utils.Mime.mimes2extList(i.mime_types)), 
                        i.mime_types.regexp = function(e) {
                            var t = [];
                            return l.each(e, function(e) {
                                l.each(e.extensions.split(/,/), function(e) {
                                    /^\s*\*\s*$/.test(e) ? t.push("\\.*") : t.push("\\." + e.replace(new RegExp("[" + "/^$.*+?|()[]{}\\".replace(/./g, "\\$&") + "]", "g"), "\\$&"));
                                });
                            }), new RegExp("(" + t.join("|") + ")$", "i");
                        }(i.mime_types), O.filters.mime_types = i.mime_types);
                        break;

                      case "resize":
                        O.resize = i ? l.extend({
                            preserve_headers: !0,
                            crop: !1
                        }, i) : !1;
                        break;

                      case "prevent_duplicates":
                        O.prevent_duplicates = O.filters.prevent_duplicates = !!i;
                        break;

                      case "container":
                      case "browse_button":
                      case "drop_element":
                        i = "container" === e ? l.get(i) : l.getAll(i);

                      case "runtimes":
                      case "multi_selection":
                      case "flash_swf_url":
                      case "silverlight_xap_url":
                        O[e] = i, n || (u = !0);
                        break;

                      default:
                        O[e] = i;
                    }
                    n || a.trigger("OptionChanged", e, i, r);
                }
                var a = this, u = !1;
                "object" == typeof e ? l.each(e, function(e, t) {
                    s(t, e, r);
                }) : s(e, i, r), r ? (O.required_features = n(l.extend({}, O)), x = n(l.extend({}, O, {
                    required_features: !0
                }))) : u && (a.trigger("Destroy"), p.call(a, O, function(e) {
                    e ? (a.runtime = o.getInfo(c()).type, a.trigger("Init", {
                        runtime: a.runtime
                    }), a.trigger("PostInit")) : a.trigger("Error", {
                        code: l.INIT_ERROR,
                        message: l.translate("Init error.")
                    });
                }));
            }
            function m(e, t) {
                if (e.settings.unique_names) {
                    var i = t.name.match(/\.([^.]+)$/), n = "part";
                    i && (n = i[1]), t.target_name = t.id + "." + n;
                }
            }
            function _(e, i) {
                function n() {
                    c-- > 0 ? r(s, 1e3) : (i.loaded = p, e.trigger("Error", {
                        code: l.HTTP_ERROR,
                        message: l.translate("HTTP Error."),
                        file: i,
                        response: T.responseText,
                        status: T.status,
                        responseHeaders: T.getAllResponseHeaders()
                    }));
                }
                function s() {
                    var t, n, r = {};
                    i.status === l.UPLOADING && e.state !== l.STOPPED && (e.settings.send_file_name && (r.name = i.target_name || i.name), 
                    d && f.chunks && o.size > d ? (n = Math.min(d, o.size - p), t = o.slice(p, p + n)) : (n = o.size, 
                    t = o), d && f.chunks && (e.settings.send_chunk_number ? (r.chunk = Math.ceil(p / d), 
                    r.chunks = Math.ceil(o.size / d)) : (r.offset = p, r.total = o.size)), e.trigger("BeforeChunkUpload", i, r, t, p) && a(r, t, n));
                }
                function a(a, d, g) {
                    var m;
                    T = new t.xhr.XMLHttpRequest(), T.upload && (T.upload.onprogress = function(t) {
                        i.loaded = Math.min(i.size, p + t.loaded), e.trigger("UploadProgress", i);
                    }), T.onload = function() {
                        return T.status < 200 || T.status >= 400 ? (n(), void 0) : (c = e.settings.max_retries, 
                        g < o.size ? (d.destroy(), p += g, i.loaded = Math.min(p, o.size), e.trigger("ChunkUploaded", i, {
                            offset: i.loaded,
                            total: o.size,
                            response: T.responseText,
                            status: T.status,
                            responseHeaders: T.getAllResponseHeaders()
                        }), "Android Browser" === l.ua.browser && e.trigger("UploadProgress", i)) : i.loaded = i.size, 
                        d = m = null, !p || p >= o.size ? (i.size != i.origSize && (o.destroy(), o = null), 
                        e.trigger("UploadProgress", i), i.status = l.DONE, i.completeTimestamp = +new Date(), 
                        e.trigger("FileUploaded", i, {
                            response: T.responseText,
                            status: T.status,
                            responseHeaders: T.getAllResponseHeaders()
                        })) : r(s, 1), void 0);
                    }, T.onerror = function() {
                        n();
                    }, T.onloadend = function() {
                        this.destroy();
                    }, e.settings.multipart && f.multipart ? (T.open(e.settings.http_method, u, !0), 
                    l.each(e.settings.headers, function(e, t) {
                        T.setRequestHeader(t, e);
                    }), m = new t.xhr.FormData(), l.each(l.extend(a, e.settings.multipart_params), function(e, t) {
                        m.append(t, e);
                    }), m.append(e.settings.file_data_name, d), T.send(m, h)) : (u = l.buildUrl(e.settings.url, l.extend(a, e.settings.multipart_params)), 
                    T.open(e.settings.http_method, u, !0), l.each(e.settings.headers, function(e, t) {
                        T.setRequestHeader(t, e);
                    }), T.hasRequestHeader("Content-Type") || T.setRequestHeader("Content-Type", "application/octet-stream"), 
                    T.send(d, h));
                }
                var o, u = e.settings.url, d = e.settings.chunk_size, c = e.settings.max_retries, f = e.features, p = 0, h = {
                    runtime_order: e.settings.runtimes,
                    required_caps: e.settings.required_features,
                    preferred_caps: x,
                    swf_url: e.settings.flash_swf_url,
                    xap_url: e.settings.silverlight_xap_url
                };
                i.loaded && (p = i.loaded = d ? d * Math.floor(i.loaded / d) : 0), o = i.getSource(), 
                l.isEmptyObj(e.settings.resize) || -1 === l.inArray(o.type, [ "image/jpeg", "image/png" ]) ? s() : g(o, e.settings.resize, h, function(e) {
                    o = e, i.size = e.size, s();
                });
            }
            function E(e, t) {
                u(t);
            }
            function v(e) {
                if (e.state == l.STARTED) S = +new Date(); else if (e.state == l.STOPPED) for (var t = e.files.length - 1; t >= 0; t--) e.files[t].status == l.UPLOADING && (e.files[t].status = l.QUEUED, 
                d());
            }
            function b() {
                T && T.abort();
            }
            function y(e) {
                d(), r(function() {
                    a.call(e);
                }, 1);
            }
            function R(e, t) {
                t.code === l.INIT_ERROR ? e.destroy() : t.code === l.HTTP_ERROR && (t.file.status = l.FAILED, 
                t.file.completeTimestamp = +new Date(), u(t.file), e.state == l.STARTED && (e.trigger("CancelUpload"), 
                r(function() {
                    a.call(e);
                }, 1)));
            }
            function z(e) {
                e.stop(), l.each(D, function(e) {
                    e.destroy();
                }), D = [], F.length && (l.each(F, function(e) {
                    e.destroy();
                }), F = []), P.length && (l.each(P, function(e) {
                    e.destroy();
                }), P = []), x = {}, U = !1, S = T = null, I.reset();
            }
            var O, S, I, T, w = l.guid(), D = [], x = {}, F = [], P = [], U = !1;
            O = {
                chunk_size: 0,
                file_data_name: "file",
                filters: {
                    mime_types: [],
                    max_file_size: 0,
                    prevent_duplicates: !1,
                    prevent_empty: !0
                },
                flash_swf_url: "js/Moxie.swf",
                http_method: "POST",
                max_retries: 0,
                multipart: !0,
                multi_selection: !0,
                resize: !1,
                runtimes: o.order,
                send_file_name: !0,
                send_chunk_number: !0,
                silverlight_xap_url: "js/Moxie.xap"
            }, h.call(this, e, null, !0), I = new l.QueueProgress(), l.extend(this, {
                id: w,
                uid: w,
                state: l.STOPPED,
                features: {},
                runtime: null,
                files: D,
                settings: O,
                total: I,
                init: function() {
                    var e, t, i = this;
                    return e = i.getOption("preinit"), "function" == typeof e ? e(i) : l.each(e, function(e, t) {
                        i.bind(t, e);
                    }), f.call(i), l.each([ "container", "browse_button", "drop_element" ], function(e) {
                        return null === i.getOption(e) ? (t = {
                            code: l.INIT_ERROR,
                            message: l.sprintf(l.translate("%s specified, but cannot be found."), e)
                        }, !1) : void 0;
                    }), t ? i.trigger("Error", t) : O.browse_button || O.drop_element ? (p.call(i, O, function(e) {
                        var t = i.getOption("init");
                        "function" == typeof t ? t(i) : l.each(t, function(e, t) {
                            i.bind(t, e);
                        }), e ? (i.runtime = o.getInfo(c()).type, i.trigger("Init", {
                            runtime: i.runtime
                        }), i.trigger("PostInit")) : i.trigger("Error", {
                            code: l.INIT_ERROR,
                            message: l.translate("Init error.")
                        });
                    }), void 0) : i.trigger("Error", {
                        code: l.INIT_ERROR,
                        message: l.translate("You must specify either browse_button or drop_element.")
                    });
                },
                setOption: function(e, t) {
                    h.call(this, e, t, !this.runtime);
                },
                getOption: function(e) {
                    return e ? O[e] : O;
                },
                refresh: function() {
                    F.length && l.each(F, function(e) {
                        e.trigger("Refresh");
                    }), this.trigger("Refresh");
                },
                start: function() {
                    this.state != l.STARTED && (this.state = l.STARTED, this.trigger("StateChanged"), 
                    a.call(this));
                },
                stop: function() {
                    this.state != l.STOPPED && (this.state = l.STOPPED, this.trigger("StateChanged"), 
                    this.trigger("CancelUpload"));
                },
                disableBrowse: function() {
                    U = arguments[0] !== i ? arguments[0] : !0, F.length && l.each(F, function(e) {
                        e.disable(U);
                    }), this.trigger("DisableBrowse", U);
                },
                getFile: function(e) {
                    var t;
                    for (t = D.length - 1; t >= 0; t--) if (D[t].id === e) return D[t];
                },
                addFile: function(e, i) {
                    function n(e, t) {
                        var i = [];
                        l.each(u.settings.filters, function(t, n) {
                            s[n] && i.push(function(i) {
                                s[n].call(u, t, e, function(e) {
                                    i(!e);
                                });
                            });
                        }), l.inSeries(i, t);
                    }
                    function a(e) {
                        var s = l.typeOf(e);
                        if (e instanceof t.file.File) {
                            if (!e.ruid && !e.isDetached()) {
                                if (!o) return !1;
                                e.ruid = o, e.connectRuntime(o);
                            }
                            a(new l.File(e));
                        } else e instanceof t.file.Blob ? (a(e.getSource()), e.destroy()) : e instanceof l.File ? (i && (e.name = i), 
                        d.push(function(t) {
                            n(e, function(i) {
                                i || (D.push(e), f.push(e), u.trigger("FileFiltered", e)), r(t, 1);
                            });
                        })) : -1 !== l.inArray(s, [ "file", "blob" ]) ? a(new t.file.File(null, e)) : "node" === s && "filelist" === l.typeOf(e.files) ? l.each(e.files, a) : "array" === s && (i = null, 
                        l.each(e, a));
                    }
                    var o, u = this, d = [], f = [];
                    o = c(), a(e), d.length && l.inSeries(d, function() {
                        f.length && u.trigger("FilesAdded", f);
                    });
                },
                removeFile: function(e) {
                    for (var t = "string" == typeof e ? e : e.id, i = D.length - 1; i >= 0; i--) if (D[i].id === t) return this.splice(i, 1)[0];
                },
                splice: function(e, t) {
                    var n = D.splice(e === i ? 0 : e, t === i ? D.length : t), r = !1;
                    return this.state == l.STARTED && (l.each(n, function(e) {
                        return e.status === l.UPLOADING ? (r = !0, !1) : void 0;
                    }), r && this.stop()), this.trigger("FilesRemoved", n), l.each(n, function(e) {
                        e.destroy();
                    }), r && this.start(), n;
                },
                dispatchEvent: function(e) {
                    var t, i;
                    if (e = e.toLowerCase(), t = this.hasEventListener(e)) {
                        t.sort(function(e, t) {
                            return t.priority - e.priority;
                        }), i = [].slice.call(arguments), i.shift(), i.unshift(this);
                        for (var n = 0; n < t.length; n++) if (t[n].fn.apply(t[n].scope, i) === !1) return !1;
                    }
                    return !0;
                },
                bind: function(e, t, i, n) {
                    l.Uploader.prototype.bind.call(this, e, t, n, i);
                },
                destroy: function() {
                    this.trigger("Destroy"), O = I = null, this.unbindAll();
                }
            });
        }, l.Uploader.prototype = t.core.EventTarget.instance, l.File = function() {
            function e(e) {
                l.extend(this, {
                    id: l.guid(),
                    name: e.name || e.fileName,
                    type: e.type || "",
                    relativePath: e.relativePath || "",
                    size: e.fileSize || e.size,
                    origSize: e.fileSize || e.size,
                    loaded: 0,
                    percent: 0,
                    status: l.QUEUED,
                    lastModifiedDate: e.lastModifiedDate || new Date().toLocaleString(),
                    completeTimestamp: 0,
                    getNative: function() {
                        var e = this.getSource().getSource();
                        return -1 !== l.inArray(l.typeOf(e), [ "blob", "file" ]) ? e : null;
                    },
                    getSource: function() {
                        return t[this.id] ? t[this.id] : null;
                    },
                    destroy: function() {
                        var e = this.getSource();
                        e && (e.destroy(), delete t[this.id]);
                    }
                }), t[this.id] = e;
            }
            var t = {};
            return e;
        }(), l.QueueProgress = function() {
            var e = this;
            e.size = 0, e.loaded = 0, e.uploaded = 0, e.failed = 0, e.queued = 0, e.percent = 0, 
            e.bytesPerSec = 0, e.reset = function() {
                e.size = e.loaded = e.uploaded = e.failed = e.queued = e.percent = e.bytesPerSec = 0;
            };
        }, e.plupload = l;
    }(this, e);
});

(function(f) {
    if (typeof exports === "object" && typeof module !== "undefined") {
        module.exports = f();
    } else if (typeof define === "function" && define.amd) {
        define([], f);
    } else {
        var g;
        if (typeof window !== "undefined") {
            g = window;
        } else if (typeof global !== "undefined") {
            g = global;
        } else if (typeof self !== "undefined") {
            g = self;
        } else {
            g = this;
        }
        g.ejs = f();
    }
})(function() {
    var define, module, exports;
    return function() {
        function r(e, n, t) {
            function o(i, f) {
                if (!n[i]) {
                    if (!e[i]) {
                        var c = "function" == typeof require && require;
                        if (!f && c) return c(i, !0);
                        if (u) return u(i, !0);
                        var a = new Error("Cannot find module '" + i + "'");
                        throw a.code = "MODULE_NOT_FOUND", a;
                    }
                    var p = n[i] = {
                        exports: {}
                    };
                    e[i][0].call(p.exports, function(r) {
                        var n = e[i][1][r];
                        return o(n || r);
                    }, p, p.exports, r, e, n, t);
                }
                return n[i].exports;
            }
            for (var u = "function" == typeof require && require, i = 0; i < t.length; i++) o(t[i]);
            return o;
        }
        return r;
    }()({
        1: [ function(require, module, exports) {
            "use strict";
            var fs = require("fs");
            var path = require("path");
            var utils = require("./utils");
            var scopeOptionWarned = false;
            var _VERSION_STRING = require("../package.json").version;
            var _DEFAULT_OPEN_DELIMITER = "<";
            var _DEFAULT_CLOSE_DELIMITER = ">";
            var _DEFAULT_DELIMITER = "%";
            var _DEFAULT_LOCALS_NAME = "locals";
            var _NAME = "ejs";
            var _REGEX_STRING = "(<%%|%%>|<%=|<%-|<%_|<%#|<%|%>|-%>|_%>)";
            var _OPTS_PASSABLE_WITH_DATA = [ "delimiter", "scope", "context", "debug", "compileDebug", "client", "_with", "rmWhitespace", "strict", "filename", "async" ];
            var _OPTS_PASSABLE_WITH_DATA_EXPRESS = _OPTS_PASSABLE_WITH_DATA.concat("cache");
            var _BOM = /^\uFEFF/;
            exports.cache = utils.cache;
            exports.fileLoader = fs.readFileSync;
            exports.localsName = _DEFAULT_LOCALS_NAME;
            exports.promiseImpl = new Function("return this;")().Promise;
            exports.resolveInclude = function(name, filename, isDir) {
                var dirname = path.dirname;
                var extname = path.extname;
                var resolve = path.resolve;
                var includePath = resolve(isDir ? filename : dirname(filename), name);
                var ext = extname(name);
                if (!ext) {
                    includePath += ".ejs";
                }
                return includePath;
            };
            function resolvePaths(name, paths) {
                var filePath;
                if (paths.some(function(v) {
                    filePath = exports.resolveInclude(name, v, true);
                    return fs.existsSync(filePath);
                })) {
                    return filePath;
                }
            }
            function getIncludePath(path, options) {
                var includePath;
                var filePath;
                var views = options.views;
                var match = /^[A-Za-z]+:\\|^\//.exec(path);
                if (match && match.length) {
                    path = path.replace(/^\/*/, "");
                    if (Array.isArray(options.root)) {
                        includePath = resolvePaths(path, options.root);
                    } else {
                        includePath = exports.resolveInclude(path, options.root || "/", true);
                    }
                } else {
                    if (options.filename) {
                        filePath = exports.resolveInclude(path, options.filename);
                        if (fs.existsSync(filePath)) {
                            includePath = filePath;
                        }
                    }
                    if (!includePath && Array.isArray(views)) {
                        includePath = resolvePaths(path, views);
                    }
                    if (!includePath && typeof options.includer !== "function") {
                        throw new Error('Could not find the include file "' + options.escapeFunction(path) + '"');
                    }
                }
                return includePath;
            }
            function handleCache(options, template) {
                var func;
                var filename = options.filename;
                var hasTemplate = arguments.length > 1;
                if (options.cache) {
                    if (!filename) {
                        throw new Error("cache option requires a filename");
                    }
                    func = exports.cache.get(filename);
                    if (func) {
                        return func;
                    }
                    if (!hasTemplate) {
                        template = fileLoader(filename).toString().replace(_BOM, "");
                    }
                } else if (!hasTemplate) {
                    if (!filename) {
                        throw new Error("Internal EJS error: no file name or template " + "provided");
                    }
                    template = fileLoader(filename).toString().replace(_BOM, "");
                }
                func = exports.compile(template, options);
                if (options.cache) {
                    exports.cache.set(filename, func);
                }
                return func;
            }
            function tryHandleCache(options, data, cb) {
                var result;
                if (!cb) {
                    if (typeof exports.promiseImpl == "function") {
                        return new exports.promiseImpl(function(resolve, reject) {
                            try {
                                result = handleCache(options)(data);
                                resolve(result);
                            } catch (err) {
                                reject(err);
                            }
                        });
                    } else {
                        throw new Error("Please provide a callback function");
                    }
                } else {
                    try {
                        result = handleCache(options)(data);
                    } catch (err) {
                        return cb(err);
                    }
                    cb(null, result);
                }
            }
            function fileLoader(filePath) {
                return exports.fileLoader(filePath);
            }
            function includeFile(path, options) {
                var opts = utils.shallowCopy({}, options);
                opts.filename = getIncludePath(path, opts);
                if (typeof options.includer === "function") {
                    var includerResult = options.includer(path, opts.filename);
                    if (includerResult) {
                        if (includerResult.filename) {
                            opts.filename = includerResult.filename;
                        }
                        if (includerResult.template) {
                            return handleCache(opts, includerResult.template);
                        }
                    }
                }
                return handleCache(opts);
            }
            function rethrow(err, str, flnm, lineno, esc) {
                var lines = str.split("\n");
                var start = Math.max(lineno - 3, 0);
                var end = Math.min(lines.length, lineno + 3);
                var filename = esc(flnm);
                var context = lines.slice(start, end).map(function(line, i) {
                    var curr = i + start + 1;
                    return (curr == lineno ? " >> " : "    ") + curr + "| " + line;
                }).join("\n");
                err.path = filename;
                err.message = (filename || "ejs") + ":" + lineno + "\n" + context + "\n\n" + err.message;
                throw err;
            }
            function stripSemi(str) {
                return str.replace(/;(\s*$)/, "$1");
            }
            exports.compile = function compile(template, opts) {
                var templ;
                if (opts && opts.scope) {
                    if (!scopeOptionWarned) {
                        console.warn("`scope` option is deprecated and will be removed in EJS 3");
                        scopeOptionWarned = true;
                    }
                    if (!opts.context) {
                        opts.context = opts.scope;
                    }
                    delete opts.scope;
                }
                templ = new Template(template, opts);
                return templ.compile();
            };
            exports.render = function(template, d, o) {
                var data = d || {};
                var opts = o || {};
                if (arguments.length == 2) {
                    utils.shallowCopyFromList(opts, data, _OPTS_PASSABLE_WITH_DATA);
                }
                return handleCache(opts, template)(data);
            };
            exports.renderFile = function() {
                var args = Array.prototype.slice.call(arguments);
                var filename = args.shift();
                var cb;
                var opts = {
                    filename: filename
                };
                var data;
                var viewOpts;
                if (typeof arguments[arguments.length - 1] == "function") {
                    cb = args.pop();
                }
                if (args.length) {
                    data = args.shift();
                    if (args.length) {
                        utils.shallowCopy(opts, args.pop());
                    } else {
                        if (data.settings) {
                            if (data.settings.views) {
                                opts.views = data.settings.views;
                            }
                            if (data.settings["view cache"]) {
                                opts.cache = true;
                            }
                            viewOpts = data.settings["view options"];
                            if (viewOpts) {
                                utils.shallowCopy(opts, viewOpts);
                            }
                        }
                        utils.shallowCopyFromList(opts, data, _OPTS_PASSABLE_WITH_DATA_EXPRESS);
                    }
                    opts.filename = filename;
                } else {
                    data = {};
                }
                return tryHandleCache(opts, data, cb);
            };
            exports.Template = Template;
            exports.clearCache = function() {
                exports.cache.reset();
            };
            function Template(text, opts) {
                opts = opts || {};
                var options = {};
                this.templateText = text;
                this.mode = null;
                this.truncate = false;
                this.currentLine = 1;
                this.source = "";
                options.client = opts.client || false;
                options.escapeFunction = opts.escape || opts.escapeFunction || utils.escapeXML;
                options.compileDebug = opts.compileDebug !== false;
                options.debug = !!opts.debug;
                options.filename = opts.filename;
                options.openDelimiter = opts.openDelimiter || exports.openDelimiter || _DEFAULT_OPEN_DELIMITER;
                options.closeDelimiter = opts.closeDelimiter || exports.closeDelimiter || _DEFAULT_CLOSE_DELIMITER;
                options.delimiter = opts.delimiter || exports.delimiter || _DEFAULT_DELIMITER;
                options.strict = opts.strict || false;
                options.context = opts.context;
                options.cache = opts.cache || false;
                options.rmWhitespace = opts.rmWhitespace;
                options.root = opts.root;
                options.includer = opts.includer;
                options.outputFunctionName = opts.outputFunctionName;
                options.localsName = opts.localsName || exports.localsName || _DEFAULT_LOCALS_NAME;
                options.views = opts.views;
                options.async = opts.async;
                options.destructuredLocals = opts.destructuredLocals;
                options.legacyInclude = typeof opts.legacyInclude != "undefined" ? !!opts.legacyInclude : true;
                if (options.strict) {
                    options._with = false;
                } else {
                    options._with = typeof opts._with != "undefined" ? opts._with : true;
                }
                this.opts = options;
                this.regex = this.createRegex();
            }
            Template.modes = {
                EVAL: "eval",
                ESCAPED: "escaped",
                RAW: "raw",
                COMMENT: "comment",
                LITERAL: "literal"
            };
            Template.prototype = {
                createRegex: function() {
                    var str = _REGEX_STRING;
                    var delim = utils.escapeRegExpChars(this.opts.delimiter);
                    var open = utils.escapeRegExpChars(this.opts.openDelimiter);
                    var close = utils.escapeRegExpChars(this.opts.closeDelimiter);
                    str = str.replace(/%/g, delim).replace(/</g, open).replace(/>/g, close);
                    return new RegExp(str);
                },
                compile: function() {
                    var src;
                    var fn;
                    var opts = this.opts;
                    var prepended = "";
                    var appended = "";
                    var escapeFn = opts.escapeFunction;
                    var ctor;
                    if (!this.source) {
                        this.generateSource();
                        prepended += '  var __output = "";\n' + "  function __append(s) { if (s !== undefined && s !== null) __output += s }\n";
                        if (opts.outputFunctionName) {
                            prepended += "  var " + opts.outputFunctionName + " = __append;" + "\n";
                        }
                        if (opts.destructuredLocals && opts.destructuredLocals.length) {
                            var destructuring = "  var __locals = (" + opts.localsName + " || {}),\n";
                            for (var i = 0; i < opts.destructuredLocals.length; i++) {
                                var name = opts.destructuredLocals[i];
                                if (i > 0) {
                                    destructuring += ",\n  ";
                                }
                                destructuring += name + " = __locals." + name;
                            }
                            prepended += destructuring + ";\n";
                        }
                        if (opts._with !== false) {
                            prepended += "  with (" + opts.localsName + " || {}) {" + "\n";
                            appended += "  }" + "\n";
                        }
                        appended += "  return __output;" + "\n";
                        this.source = prepended + this.source + appended;
                    }
                    if (opts.compileDebug) {
                        src = "var __line = 1" + "\n" + "  , __lines = " + JSON.stringify(this.templateText) + "\n" + "  , __filename = " + (opts.filename ? JSON.stringify(opts.filename) : "undefined") + ";" + "\n" + "try {" + "\n" + this.source + "} catch (e) {" + "\n" + "  rethrow(e, __lines, __filename, __line, escapeFn);" + "\n" + "}" + "\n";
                    } else {
                        src = this.source;
                    }
                    if (opts.client) {
                        src = "escapeFn = escapeFn || " + escapeFn.toString() + ";" + "\n" + src;
                        if (opts.compileDebug) {
                            src = "rethrow = rethrow || " + rethrow.toString() + ";" + "\n" + src;
                        }
                    }
                    if (opts.strict) {
                        src = '"use strict";\n' + src;
                    }
                    if (opts.debug) {
                        console.log(src);
                    }
                    if (opts.compileDebug && opts.filename) {
                        src = src + "\n" + "//# sourceURL=" + opts.filename + "\n";
                    }
                    try {
                        if (opts.async) {
                            try {
                                ctor = new Function("return (async function(){}).constructor;")();
                            } catch (e) {
                                if (e instanceof SyntaxError) {
                                    throw new Error("This environment does not support async/await");
                                } else {
                                    throw e;
                                }
                            }
                        } else {
                            ctor = Function;
                        }
                        fn = new ctor(opts.localsName + ", escapeFn, include, rethrow", src);
                    } catch (e) {
                        if (e instanceof SyntaxError) {
                            if (opts.filename) {
                                e.message += " in " + opts.filename;
                            }
                            e.message += " while compiling ejs\n\n";
                            e.message += "If the above error is not helpful, you may want to try EJS-Lint:\n";
                            e.message += "https://github.com/RyanZim/EJS-Lint";
                            if (!opts.async) {
                                e.message += "\n";
                                e.message += "Or, if you meant to create an async function, pass `async: true` as an option.";
                            }
                        }
                        throw e;
                    }
                    var returnedFn = opts.client ? fn : function anonymous(data) {
                        var include = function(path, includeData) {
                            var d = utils.shallowCopy({}, data);
                            if (includeData) {
                                d = utils.shallowCopy(d, includeData);
                            }
                            return includeFile(path, opts)(d);
                        };
                        return fn.apply(opts.context, [ data || {}, escapeFn, include, rethrow ]);
                    };
                    if (opts.filename && typeof Object.defineProperty === "function") {
                        var filename = opts.filename;
                        var basename = path.basename(filename, path.extname(filename));
                        try {
                            Object.defineProperty(returnedFn, "name", {
                                value: basename,
                                writable: false,
                                enumerable: false,
                                configurable: true
                            });
                        } catch (e) {}
                    }
                    return returnedFn;
                },
                generateSource: function() {
                    var opts = this.opts;
                    if (opts.rmWhitespace) {
                        this.templateText = this.templateText.replace(/[\r\n]+/g, "\n").replace(/^\s+|\s+$/gm, "");
                    }
                    this.templateText = this.templateText.replace(/[ \t]*<%_/gm, "<%_").replace(/_%>[ \t]*/gm, "_%>");
                    var self = this;
                    var matches = this.parseTemplateText();
                    var d = this.opts.delimiter;
                    var o = this.opts.openDelimiter;
                    var c = this.opts.closeDelimiter;
                    if (matches && matches.length) {
                        matches.forEach(function(line, index) {
                            var closing;
                            if (line.indexOf(o + d) === 0 && line.indexOf(o + d + d) !== 0) {
                                closing = matches[index + 2];
                                if (!(closing == d + c || closing == "-" + d + c || closing == "_" + d + c)) {
                                    throw new Error('Could not find matching close tag for "' + line + '".');
                                }
                            }
                            self.scanLine(line);
                        });
                    }
                },
                parseTemplateText: function() {
                    var str = this.templateText;
                    var pat = this.regex;
                    var result = pat.exec(str);
                    var arr = [];
                    var firstPos;
                    while (result) {
                        firstPos = result.index;
                        if (firstPos !== 0) {
                            arr.push(str.substring(0, firstPos));
                            str = str.slice(firstPos);
                        }
                        arr.push(result[0]);
                        str = str.slice(result[0].length);
                        result = pat.exec(str);
                    }
                    if (str) {
                        arr.push(str);
                    }
                    return arr;
                },
                _addOutput: function(line) {
                    if (this.truncate) {
                        line = line.replace(/^(?:\r\n|\r|\n)/, "");
                        this.truncate = false;
                    }
                    if (!line) {
                        return line;
                    }
                    line = line.replace(/\\/g, "\\\\");
                    line = line.replace(/\n/g, "\\n");
                    line = line.replace(/\r/g, "\\r");
                    line = line.replace(/"/g, '\\"');
                    this.source += '    ; __append("' + line + '")' + "\n";
                },
                scanLine: function(line) {
                    var self = this;
                    var d = this.opts.delimiter;
                    var o = this.opts.openDelimiter;
                    var c = this.opts.closeDelimiter;
                    var newLineCount = 0;
                    newLineCount = line.split("\n").length - 1;
                    switch (line) {
                      case o + d:
                      case o + d + "_":
                        this.mode = Template.modes.EVAL;
                        break;

                      case o + d + "=":
                        this.mode = Template.modes.ESCAPED;
                        break;

                      case o + d + "-":
                        this.mode = Template.modes.RAW;
                        break;

                      case o + d + "#":
                        this.mode = Template.modes.COMMENT;
                        break;

                      case o + d + d:
                        this.mode = Template.modes.LITERAL;
                        this.source += '    ; __append("' + line.replace(o + d + d, o + d) + '")' + "\n";
                        break;

                      case d + d + c:
                        this.mode = Template.modes.LITERAL;
                        this.source += '    ; __append("' + line.replace(d + d + c, d + c) + '")' + "\n";
                        break;

                      case d + c:
                      case "-" + d + c:
                      case "_" + d + c:
                        if (this.mode == Template.modes.LITERAL) {
                            this._addOutput(line);
                        }
                        this.mode = null;
                        this.truncate = line.indexOf("-") === 0 || line.indexOf("_") === 0;
                        break;

                      default:
                        if (this.mode) {
                            switch (this.mode) {
                              case Template.modes.EVAL:
                              case Template.modes.ESCAPED:
                              case Template.modes.RAW:
                                if (line.lastIndexOf("//") > line.lastIndexOf("\n")) {
                                    line += "\n";
                                }
                            }
                            switch (this.mode) {
                              case Template.modes.EVAL:
                                this.source += "    ; " + line + "\n";
                                break;

                              case Template.modes.ESCAPED:
                                this.source += "    ; __append(escapeFn(" + stripSemi(line) + "))" + "\n";
                                break;

                              case Template.modes.RAW:
                                this.source += "    ; __append(" + stripSemi(line) + ")" + "\n";
                                break;

                              case Template.modes.COMMENT:
                                break;

                              case Template.modes.LITERAL:
                                this._addOutput(line);
                                break;
                            }
                        } else {
                            this._addOutput(line);
                        }
                    }
                    if (self.opts.compileDebug && newLineCount) {
                        this.currentLine += newLineCount;
                        this.source += "    ; __line = " + this.currentLine + "\n";
                    }
                }
            };
            exports.escapeXML = utils.escapeXML;
            exports.__express = exports.renderFile;
            exports.VERSION = _VERSION_STRING;
            exports.name = _NAME;
            if (typeof window != "undefined") {
                window.ejs = exports;
            }
        }, {
            "../package.json": 6,
            "./utils": 2,
            fs: 3,
            path: 4
        } ],
        2: [ function(require, module, exports) {
            "use strict";
            var regExpChars = /[|\\{}()[\]^$+*?.]/g;
            exports.escapeRegExpChars = function(string) {
                if (!string) {
                    return "";
                }
                return String(string).replace(regExpChars, "\\$&");
            };
            var _ENCODE_HTML_RULES = {
                "&": "&amp;",
                "<": "&lt;",
                ">": "&gt;",
                '"': "&#34;",
                "'": "&#39;"
            };
            var _MATCH_HTML = /[&<>'"]/g;
            function encode_char(c) {
                return _ENCODE_HTML_RULES[c] || c;
            }
            var escapeFuncStr = "var _ENCODE_HTML_RULES = {\n" + '      "&": "&amp;"\n' + '    , "<": "&lt;"\n' + '    , ">": "&gt;"\n' + '    , \'"\': "&#34;"\n' + '    , "\'": "&#39;"\n' + "    }\n" + "  , _MATCH_HTML = /[&<>'\"]/g;\n" + "function encode_char(c) {\n" + "  return _ENCODE_HTML_RULES[c] || c;\n" + "};\n";
            exports.escapeXML = function(markup) {
                return markup == undefined ? "" : String(markup).replace(_MATCH_HTML, encode_char);
            };
            exports.escapeXML.toString = function() {
                return Function.prototype.toString.call(this) + ";\n" + escapeFuncStr;
            };
            exports.shallowCopy = function(to, from) {
                from = from || {};
                for (var p in from) {
                    to[p] = from[p];
                }
                return to;
            };
            exports.shallowCopyFromList = function(to, from, list) {
                for (var i = 0; i < list.length; i++) {
                    var p = list[i];
                    if (typeof from[p] != "undefined") {
                        to[p] = from[p];
                    }
                }
                return to;
            };
            exports.cache = {
                _data: {},
                set: function(key, val) {
                    this._data[key] = val;
                },
                get: function(key) {
                    return this._data[key];
                },
                remove: function(key) {
                    delete this._data[key];
                },
                reset: function() {
                    this._data = {};
                }
            };
            exports.hyphenToCamel = function(str) {
                return str.replace(/-[a-z]/g, function(match) {
                    return match[1].toUpperCase();
                });
            };
        }, {} ],
        3: [ function(require, module, exports) {}, {} ],
        4: [ function(require, module, exports) {
            (function(process) {
                function normalizeArray(parts, allowAboveRoot) {
                    var up = 0;
                    for (var i = parts.length - 1; i >= 0; i--) {
                        var last = parts[i];
                        if (last === ".") {
                            parts.splice(i, 1);
                        } else if (last === "..") {
                            parts.splice(i, 1);
                            up++;
                        } else if (up) {
                            parts.splice(i, 1);
                            up--;
                        }
                    }
                    if (allowAboveRoot) {
                        for (;up--; up) {
                            parts.unshift("..");
                        }
                    }
                    return parts;
                }
                exports.resolve = function() {
                    var resolvedPath = "", resolvedAbsolute = false;
                    for (var i = arguments.length - 1; i >= -1 && !resolvedAbsolute; i--) {
                        var path = i >= 0 ? arguments[i] : process.cwd();
                        if (typeof path !== "string") {
                            throw new TypeError("Arguments to path.resolve must be strings");
                        } else if (!path) {
                            continue;
                        }
                        resolvedPath = path + "/" + resolvedPath;
                        resolvedAbsolute = path.charAt(0) === "/";
                    }
                    resolvedPath = normalizeArray(filter(resolvedPath.split("/"), function(p) {
                        return !!p;
                    }), !resolvedAbsolute).join("/");
                    return (resolvedAbsolute ? "/" : "") + resolvedPath || ".";
                };
                exports.normalize = function(path) {
                    var isAbsolute = exports.isAbsolute(path), trailingSlash = substr(path, -1) === "/";
                    path = normalizeArray(filter(path.split("/"), function(p) {
                        return !!p;
                    }), !isAbsolute).join("/");
                    if (!path && !isAbsolute) {
                        path = ".";
                    }
                    if (path && trailingSlash) {
                        path += "/";
                    }
                    return (isAbsolute ? "/" : "") + path;
                };
                exports.isAbsolute = function(path) {
                    return path.charAt(0) === "/";
                };
                exports.join = function() {
                    var paths = Array.prototype.slice.call(arguments, 0);
                    return exports.normalize(filter(paths, function(p, index) {
                        if (typeof p !== "string") {
                            throw new TypeError("Arguments to path.join must be strings");
                        }
                        return p;
                    }).join("/"));
                };
                exports.relative = function(from, to) {
                    from = exports.resolve(from).substr(1);
                    to = exports.resolve(to).substr(1);
                    function trim(arr) {
                        var start = 0;
                        for (;start < arr.length; start++) {
                            if (arr[start] !== "") break;
                        }
                        var end = arr.length - 1;
                        for (;end >= 0; end--) {
                            if (arr[end] !== "") break;
                        }
                        if (start > end) return [];
                        return arr.slice(start, end - start + 1);
                    }
                    var fromParts = trim(from.split("/"));
                    var toParts = trim(to.split("/"));
                    var length = Math.min(fromParts.length, toParts.length);
                    var samePartsLength = length;
                    for (var i = 0; i < length; i++) {
                        if (fromParts[i] !== toParts[i]) {
                            samePartsLength = i;
                            break;
                        }
                    }
                    var outputParts = [];
                    for (var i = samePartsLength; i < fromParts.length; i++) {
                        outputParts.push("..");
                    }
                    outputParts = outputParts.concat(toParts.slice(samePartsLength));
                    return outputParts.join("/");
                };
                exports.sep = "/";
                exports.delimiter = ":";
                exports.dirname = function(path) {
                    if (typeof path !== "string") path = path + "";
                    if (path.length === 0) return ".";
                    var code = path.charCodeAt(0);
                    var hasRoot = code === 47;
                    var end = -1;
                    var matchedSlash = true;
                    for (var i = path.length - 1; i >= 1; --i) {
                        code = path.charCodeAt(i);
                        if (code === 47) {
                            if (!matchedSlash) {
                                end = i;
                                break;
                            }
                        } else {
                            matchedSlash = false;
                        }
                    }
                    if (end === -1) return hasRoot ? "/" : ".";
                    if (hasRoot && end === 1) {
                        return "/";
                    }
                    return path.slice(0, end);
                };
                function basename(path) {
                    if (typeof path !== "string") path = path + "";
                    var start = 0;
                    var end = -1;
                    var matchedSlash = true;
                    var i;
                    for (i = path.length - 1; i >= 0; --i) {
                        if (path.charCodeAt(i) === 47) {
                            if (!matchedSlash) {
                                start = i + 1;
                                break;
                            }
                        } else if (end === -1) {
                            matchedSlash = false;
                            end = i + 1;
                        }
                    }
                    if (end === -1) return "";
                    return path.slice(start, end);
                }
                exports.basename = function(path, ext) {
                    var f = basename(path);
                    if (ext && f.substr(-1 * ext.length) === ext) {
                        f = f.substr(0, f.length - ext.length);
                    }
                    return f;
                };
                exports.extname = function(path) {
                    if (typeof path !== "string") path = path + "";
                    var startDot = -1;
                    var startPart = 0;
                    var end = -1;
                    var matchedSlash = true;
                    var preDotState = 0;
                    for (var i = path.length - 1; i >= 0; --i) {
                        var code = path.charCodeAt(i);
                        if (code === 47) {
                            if (!matchedSlash) {
                                startPart = i + 1;
                                break;
                            }
                            continue;
                        }
                        if (end === -1) {
                            matchedSlash = false;
                            end = i + 1;
                        }
                        if (code === 46) {
                            if (startDot === -1) startDot = i; else if (preDotState !== 1) preDotState = 1;
                        } else if (startDot !== -1) {
                            preDotState = -1;
                        }
                    }
                    if (startDot === -1 || end === -1 || preDotState === 0 || preDotState === 1 && startDot === end - 1 && startDot === startPart + 1) {
                        return "";
                    }
                    return path.slice(startDot, end);
                };
                function filter(xs, f) {
                    if (xs.filter) return xs.filter(f);
                    var res = [];
                    for (var i = 0; i < xs.length; i++) {
                        if (f(xs[i], i, xs)) res.push(xs[i]);
                    }
                    return res;
                }
                var substr = "ab".substr(-1) === "b" ? function(str, start, len) {
                    return str.substr(start, len);
                } : function(str, start, len) {
                    if (start < 0) start = str.length + start;
                    return str.substr(start, len);
                };
            }).call(this, require("_process"));
        }, {
            _process: 5
        } ],
        5: [ function(require, module, exports) {
            var process = module.exports = {};
            var cachedSetTimeout;
            var cachedClearTimeout;
            function defaultSetTimout() {
                throw new Error("setTimeout has not been defined");
            }
            function defaultClearTimeout() {
                throw new Error("clearTimeout has not been defined");
            }
            (function() {
                try {
                    if (typeof setTimeout === "function") {
                        cachedSetTimeout = setTimeout;
                    } else {
                        cachedSetTimeout = defaultSetTimout;
                    }
                } catch (e) {
                    cachedSetTimeout = defaultSetTimout;
                }
                try {
                    if (typeof clearTimeout === "function") {
                        cachedClearTimeout = clearTimeout;
                    } else {
                        cachedClearTimeout = defaultClearTimeout;
                    }
                } catch (e) {
                    cachedClearTimeout = defaultClearTimeout;
                }
            })();
            function runTimeout(fun) {
                if (cachedSetTimeout === setTimeout) {
                    return setTimeout(fun, 0);
                }
                if ((cachedSetTimeout === defaultSetTimout || !cachedSetTimeout) && setTimeout) {
                    cachedSetTimeout = setTimeout;
                    return setTimeout(fun, 0);
                }
                try {
                    return cachedSetTimeout(fun, 0);
                } catch (e) {
                    try {
                        return cachedSetTimeout.call(null, fun, 0);
                    } catch (e) {
                        return cachedSetTimeout.call(this, fun, 0);
                    }
                }
            }
            function runClearTimeout(marker) {
                if (cachedClearTimeout === clearTimeout) {
                    return clearTimeout(marker);
                }
                if ((cachedClearTimeout === defaultClearTimeout || !cachedClearTimeout) && clearTimeout) {
                    cachedClearTimeout = clearTimeout;
                    return clearTimeout(marker);
                }
                try {
                    return cachedClearTimeout(marker);
                } catch (e) {
                    try {
                        return cachedClearTimeout.call(null, marker);
                    } catch (e) {
                        return cachedClearTimeout.call(this, marker);
                    }
                }
            }
            var queue = [];
            var draining = false;
            var currentQueue;
            var queueIndex = -1;
            function cleanUpNextTick() {
                if (!draining || !currentQueue) {
                    return;
                }
                draining = false;
                if (currentQueue.length) {
                    queue = currentQueue.concat(queue);
                } else {
                    queueIndex = -1;
                }
                if (queue.length) {
                    drainQueue();
                }
            }
            function drainQueue() {
                if (draining) {
                    return;
                }
                var timeout = runTimeout(cleanUpNextTick);
                draining = true;
                var len = queue.length;
                while (len) {
                    currentQueue = queue;
                    queue = [];
                    while (++queueIndex < len) {
                        if (currentQueue) {
                            currentQueue[queueIndex].run();
                        }
                    }
                    queueIndex = -1;
                    len = queue.length;
                }
                currentQueue = null;
                draining = false;
                runClearTimeout(timeout);
            }
            process.nextTick = function(fun) {
                var args = new Array(arguments.length - 1);
                if (arguments.length > 1) {
                    for (var i = 1; i < arguments.length; i++) {
                        args[i - 1] = arguments[i];
                    }
                }
                queue.push(new Item(fun, args));
                if (queue.length === 1 && !draining) {
                    runTimeout(drainQueue);
                }
            };
            function Item(fun, array) {
                this.fun = fun;
                this.array = array;
            }
            Item.prototype.run = function() {
                this.fun.apply(null, this.array);
            };
            process.title = "browser";
            process.browser = true;
            process.env = {};
            process.argv = [];
            process.version = "";
            process.versions = {};
            function noop() {}
            process.on = noop;
            process.addListener = noop;
            process.once = noop;
            process.off = noop;
            process.removeListener = noop;
            process.removeAllListeners = noop;
            process.emit = noop;
            process.prependListener = noop;
            process.prependOnceListener = noop;
            process.listeners = function(name) {
                return [];
            };
            process.binding = function(name) {
                throw new Error("process.binding is not supported");
            };
            process.cwd = function() {
                return "/";
            };
            process.chdir = function(dir) {
                throw new Error("process.chdir is not supported");
            };
            process.umask = function() {
                return 0;
            };
        }, {} ],
        6: [ function(require, module, exports) {
            module.exports = {
                name: "ejs",
                description: "Embedded JavaScript templates",
                keywords: [ "template", "engine", "ejs" ],
                version: "3.1.5",
                author: "Matthew Eernisse <mde@fleegix.org> (http://fleegix.org)",
                license: "Apache-2.0",
                bin: {
                    ejs: "./bin/cli.js"
                },
                main: "./lib/ejs.js",
                jsdelivr: "ejs.min.js",
                unpkg: "ejs.min.js",
                repository: {
                    type: "git",
                    url: "git://github.com/mde/ejs.git"
                },
                bugs: "https://github.com/mde/ejs/issues",
                homepage: "https://github.com/mde/ejs",
                dependencies: {
                    jake: "^10.6.1"
                },
                devDependencies: {
                    browserify: "^16.5.1",
                    eslint: "^6.8.0",
                    "git-directory-deploy": "^1.5.1",
                    jsdoc: "^3.6.4",
                    "lru-cache": "^4.0.1",
                    mocha: "^7.1.1",
                    "uglify-js": "^3.3.16"
                },
                engines: {
                    node: ">=0.10.0"
                },
                scripts: {
                    test: "mocha"
                }
            };
        }, {} ]
    }, {}, [ 1 ])(1);
});

(function(window, $) {
    var TinyAutocomplete = function(el, options) {
        var that = this;
        that.field = $(el);
        that.el = null;
        that.json = null;
        that.items = [];
        that.selectedItem = null;
        that.list = $('<ul class="autocomplete-list" />');
        that.lastSearch = null;
        that.options = options;
    };
    TinyAutocomplete.prototype = {
        defaults: {
            minChars: 2,
            markAsBold: true,
            grouped: false,
            queryProperty: "q",
            queryParameters: {},
            method: "get",
            scrollOnFocus: "auto",
            maxItems: 100,
            keyboardDelay: 300,
            lastItemTemplate: null,
            closeOnSelect: true,
            groupContentName: ".autocomplete-items",
            groupTemplate: '<li class="autocomplete-group"><span class="autocomplete-group-header">{{title}}</span><ul class="autocomplete-items" /></li>',
            itemTemplate: '<li class="autocomplete-item">{{title}}</li>',
            showNoResults: false,
            noResultsTemplate: '<li class="autocomplete-item">No results for {{title}}</li>',
            wrapClasses: "autocomplete"
        },
        init: function() {
            this.defaults.templateMethod = this.template;
            this.settings = $.extend({}, this.defaults, this.options);
            this.setupSettings();
            this.setupMarkup();
            this.setupEvents();
            return this;
        },
        template: function(template, vars) {
            return template.replace(/{{\s*[\w]+\s*}}/g, function(v) {
                return vars[v.substr(2, v.length - 4)];
            });
        },
        debounce: function(func, wait, immediate) {
            var timeout;
            return function() {
                var context = this, args = arguments;
                var later = function() {
                    timeout = null;
                    if (!immediate) func.apply(context, args);
                };
                var callNow = immediate && !timeout;
                clearTimeout(timeout);
                timeout = setTimeout(later, wait);
                if (callNow) func.apply(context, args);
            };
        },
        setupSettings: function() {
            if (this.settings.scrollOnFocus == "auto") {
                this.settings.scrollOnFocus = this.isTouchDevice();
            }
            if ($(window).height() < 500) {
                this.settings.maxItems = Math.min(this.settings.maxItems, 3);
            }
            if (this.settings.data) {
                this.request = this.localRequest;
            } else {
                this.request = this.remoteRequest;
            }
            if (this.settings.keyboardDelay != null) {
                this.request = this.debounce(this.request, this.settings.keyboardDelay);
            }
        },
        setupEvents: function() {
            this.el.on("keyup", ".autocomplete-field", $.proxy(this.onKeyUp, this));
            this.el.on("keydown", ".autocomplete-field", $.proxy(this.onKeyDown, this));
            this.el.on("click", ".autocomplete-item", $.proxy(this.onClickItem, this));
            if (this.settings.scrollOnFocus) {
                this.field.on("focus", function() {
                    var h = $(this).offset().top;
                    setTimeout(function() {
                        window.scrollTo(0, h);
                    }, 0);
                });
            }
        },
        setupMarkup: function() {
            this.field.addClass("autocomplete-field");
            this.field.attr("autocomplete", "off");
            this.field.wrap('<div class="' + this.settings.wrapClasses + '" />');
            this.el = this.field.parent();
        },
        remoteRequest: function(val) {
            this.field.trigger("beforerequest", [ this, val ]);
            var data = {};
            $.extend(data, this.settings.queryParameters);
            data[this.settings.queryProperty] = val;
            $.ajax({
                method: this.settings.method,
                url: this.settings.url,
                dataType: "json",
                data: data,
                success: $.proxy(this.beforeReceiveData, this)
            });
        },
        localRequest: function(val) {
            if (this.settings.grouped) {
                this.beforeReceiveData(this.matchLocalPatternGrouped(val));
            } else {
                this.beforeReceiveData(this.matchLocalPatternFlat(val));
            }
        },
        matchLocalPatternFlat: function(val) {
            return this.matchArray(val, this.settings.data);
        },
        matchLocalPatternGrouped: function(val) {
            var r = $.extend(true, [], this.settings.data);
            for (var i = 0; i < r.length; i++) {
                var a = this.matchArray(val, r[i].data);
                if (a.length == 0) {
                    r.splice(i, 1);
                    i--;
                } else {
                    r[i].data = a;
                }
            }
            return r;
        },
        matchArray: function(val, arr) {
            var r = [];
            for (var i = 0; i < arr.length; i++) {
                for (var j in arr[i]) {
                    if (arr[i][j].toLowerCase && arr[i][j].toLowerCase().indexOf(val.toLowerCase()) > -1 || arr[i][j] == val) {
                        r.push(arr[i]);
                        break;
                    }
                }
            }
            return r;
        },
        itemAt: function(i) {
            if (i == null) {
                return $();
            }
            return this.el.find(".autocomplete-item").eq(i);
        },
        clickedItemAt: function(o) {
            for (var i = 0; i < this.items.length; i++) {
                if (o == this.el.find(".autocomplete-item").eq(i).get(0)) {
                    return i;
                }
            }
            return null;
        },
        prevItem: function() {
            this.selectedItem--;
            if (this.selectedItem < 0) {
                this.selectedItem = null;
            }
            this.markSelected(this.selectedItem);
        },
        nextItem: function() {
            if (this.selectedItem == null) {
                this.selectedItem = -1;
            }
            this.selectedItem++;
            var l = this.settings.lastItemTemplate ? this.items.length : this.items.length - 1;
            if (this.selectedItem >= l) {
                this.selectedItem = l;
            }
            this.markSelected(this.selectedItem);
        },
        markSelected: function(i) {
            this.el.find(".active").removeClass("active");
            this.itemAt(i).addClass("active");
        },
        markHitText: function(v, str) {
            var words = str.split(" ");
            for (var i in v) {
                if (typeof v[i] == "string" && i != "template") {
                    var replacements = [ str ];
                    for (var j = 0; j < words.length; j++) {
                        var word = words[j].trim().replace(/[^a-ö0-9]/gi, "");
                        if (word.length > 0) {
                            replacements.push(word);
                        }
                    }
                    v[i] = v[i].replace(new RegExp("(" + replacements.join("|") + ")", "gi"), "<strong>$1</strong>");
                }
            }
            return v;
        },
        renderGroups: function() {
            this.list.remove();
            this.list = $('<ul class="autocomplete-list" />');
            for (var i in this.json) {
                this.list.append(this.settings.templateMethod(this.settings.groupTemplate, this.json[i]));
            }
            this.el.append(this.list);
        },
        renderItemsInGroups: function() {
            var v = this.field.val();
            for (var i = 0; i < this.json.length; i++) {
                var group = this.el.find(this.settings.groupContentName).eq(i);
                for (var j = 0; j < this.json[i].data.length && j < this.settings.maxItems; j++) {
                    var jsonData = $.extend({}, this.json[i].data[j]);
                    if (this.settings.markAsBold) {
                        jsonData = this.markHitText(jsonData, v);
                    }
                    group.append(this.settings.templateMethod(this.json[i].template || this.settings.itemTemplate, jsonData));
                }
            }
        },
        renderItemsFlat: function() {
            this.list.remove();
            this.list = $('<ul class="autocomplete-list" />');
            var v = this.field.val();
            for (var i = 0; i < this.json.length && i < this.settings.maxItems; i++) {
                var jsonData = $.extend({}, this.json[i]);
                if (this.settings.markAsBold) {
                    jsonData = this.markHitText(jsonData, v);
                }
                this.list.append(this.settings.templateMethod(this.json[i].template || this.settings.itemTemplate, jsonData));
            }
            this.el.append(this.list);
        },
        renderLastItem: function() {
            this.list.append(this.settings.templateMethod(this.settings.lastItemTemplate, {
                title: this.field.val()
            }));
        },
        renderNoResults: function() {
            this.list.append(this.settings.templateMethod(this.settings.noResultsTemplate, {
                title: this.field.val()
            }));
        },
        closeList: function() {
            $("html").off("click");
            this.list.remove();
            this.selectedItem = null;
        },
        getItemsFromGroups: function() {
            var r = [];
            for (var i in this.json) {
                for (var j = 0; j < this.json[i].data.length; j++) {
                    if (j < this.settings.maxItems) {
                        r.push(this.json[i].data[j]);
                    }
                }
            }
            return r;
        },
        valueHasChanged: function() {
            if (this.field.val() != this.lastSearch) {
                this.lastSearch = this.field.val();
                return true;
            }
            return false;
        },
        isTouchDevice: function() {
            return !!("ontouchstart" in window);
        },
        beforeReceiveData: function(data, xhr) {
            this.json = data;
            this.field.trigger("receivedata", [ this, data, xhr ]);
            this.onReceiveData(this.json);
        },
        onReceiveData: function(data) {
            this.selectedItem = null;
            if (this.settings.grouped) {
                this.renderGroups();
                this.items = this.getItemsFromGroups();
                this.renderItemsInGroups();
            } else {
                this.items = this.json;
                this.renderItemsFlat();
            }
            if (!this.items.length) {
                if (this.settings.showNoResults) {
                    this.renderNoResults();
                }
            }
            if (this.settings.lastItemTemplate) {
                this.renderLastItem();
            }
            $("html").one("click", $.proxy(this.closeList, this));
        },
        onKeyUp: function(e) {
            if (this.field.val().length >= this.settings.minChars && this.valueHasChanged()) {
                this.request(this.field.val());
            }
            if (this.field.val() == "") {
                this.lastSearch = "";
                this.closeList();
            }
        },
        onKeyDown: function(e) {
            if (e.keyCode == 38) {
                e.preventDefault();
                this.prevItem();
            }
            if (e.keyCode == 40) {
                e.preventDefault();
                this.nextItem();
            }
            if (e.keyCode == 13) {
                this.onPressEnter(e);
            }
            if (e.keyCode == 27) {
                e.preventDefault();
                this.closeList();
            }
        },
        onClickItem: function(e) {
            var i = this.clickedItemAt(e.currentTarget);
            this.onSelect(e.currentTarget, this.items[i]);
        },
        onPressEnter: function(e) {
            if (this.selectedItem === null) {
                return true;
            }
            e.preventDefault();
            this.onSelect(this.itemAt(this.selectedItem), this.items[this.selectedItem]);
        },
        onSelect: function(item, val) {
            if (this.settings.onSelect) {
                this.settings.onSelect.apply(this.field, [ item, val ]);
            }
            this.lastSearch = this.field.val();
            if (this.settings.closeOnSelect) {
                this.closeList();
            }
        }
    };
    TinyAutocomplete.defaults = TinyAutocomplete.prototype.defaults;
    $.fn.tinyAutocomplete = function(settings) {
        return this.each(function() {
            if (this.tinyAutocomplete) {
                $.extend(this.tinyAutocomplete.settings, settings);
                return this;
            }
            var d = new TinyAutocomplete(this, settings).init();
            this.tinyAutocomplete = {
                settings: d.settings
            };
        });
    };
    $.tinyAutocomplete = TinyAutocomplete;
})(window, $);

var indexOf = [].indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
        if (i in this && this[i] === item) return i;
    }
    return -1;
};

Zepto.extend(Zepto.ajaxSettings, {
    type: "GET",
    dataType: "json",
    contentType: "application/json",
    beforeSend: function(xhr, settings) {
        wApp.state.requests.push(xhr);
        wApp.bus.trigger("ajax-state-changed");
        xhr.then(function() {
            return console.log("ajax " + settings.type + ": ", xhr.requestUrl, JSON.parse(xhr.response));
        });
        xhr.always(function() {
            wApp.state.requests.pop();
            return wApp.bus.trigger("ajax-state-changed");
        });
        xhr.fail(function(xhr) {
            if (xhr.status === 401) {
                return wApp.bus.trigger("reload-session");
            }
        });
        xhr.requestUrl = settings.url;
        if (settings.type.match(/POST|PATCH|PUT|DELETE/i) && wApp.session) {
            return xhr.setRequestHeader("X-CSRF-Token", wApp.session.csrfToken());
        }
    }
});

$.tinyAutocomplete.prototype.beforeReceiveData = function(data, xhr) {
    this.json = data.records;
    this.field.trigger("receivedata", [ this, data, xhr ]);
    return this.onReceiveData(this.json);
};

window.wApp = {
    bus: riot.observable(),
    mixins: {},
    state: {
        requests: []
    },
    setup: function() {
        wApp.clipboard.setup();
        wApp.entityHistory.setup();
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
                return wApp.bus.trigger("reload-session");
            }
        });
    },
    logout: function() {
        return Zepto.ajax({
            type: "delete",
            url: "/logout",
            success: function(data) {
                wApp.bus.trigger("reload-session");
                return wApp.routing.path("/");
            }
        });
    }
};

wApp.mixins.auth = {
    isAdmin: function() {
        if (!this.currentUser()) {
            return false;
        }
        return !!this.currentUser().admin;
    },
    isAuthorityGroupAdmin: function() {
        if (!this.currentUser()) {
            return false;
        }
        return !!this.currentUser().authority_group_admin;
    },
    isRelationAdmin: function() {
        if (!this.currentUser()) {
            return false;
        }
        return !!this.currentUser().relation_admin;
    },
    isKindAdmin: function() {
        if (!this.currentUser()) {
            return false;
        }
        return !!this.currentUser().kind_admin;
    },
    hasAnyRole: function() {
        return this.isAdmin() || this.isAuthorityGroupAdmin() || this.isRelationAdmin() || this.isKindAdmin();
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

wApp.clipboard = {
    add: function(id) {
        Lockr.sadd("clipboard", id);
        return wApp.bus.trigger("clipboard-changed");
    },
    remove: function(id) {
        Lockr.srem("clipboard", id);
        wApp.bus.trigger("clipboard-changed");
        if (wApp.clipboard.subSelected(id)) {
            return wApp.clipboard.unSubSelect(id);
        }
    },
    includes: function(id) {
        return Lockr.sismember("clipboard", id);
    },
    select: function(id) {
        Lockr.set("selection", id);
        return wApp.bus.trigger("clipboard-changed");
    },
    unselect: function() {
        Lockr.rm("selection");
        return wApp.bus.trigger("clipboard-changed");
    },
    selected: function(id) {
        return wApp.clipboard.selection() === id;
    },
    selection: function() {
        return Lockr.get("selection");
    },
    reset: function() {
        Lockr.rm("clipboard");
        wApp.clipboard.unselect();
        return wApp.clipboard.resetSubSelection();
    },
    ids: function() {
        return Lockr.smembers("clipboard");
    },
    setup: function() {
        return wApp.bus.on("logout", function() {
            return wApp.clipboard.reset();
        });
    },
    subSelect: function(id) {
        Lockr.sadd("clipboard-subselection", id);
        return wApp.bus.trigger("clipboard-subselection-changed");
    },
    unSubSelect: function(id) {
        Lockr.srem("clipboard-subselection", id);
        return wApp.bus.trigger("clipboard-subselection-changed");
    },
    resetSubSelection: function() {
        Lockr.rm("clipboard-subselection");
        return wApp.bus.trigger("clipboard-subselection-changed");
    },
    subSelected: function(id) {
        return Lockr.sismember("clipboard-subselection", id);
    },
    subSelection: function() {
        return Lockr.smembers("clipboard-subselection");
    },
    subSelectAll: function() {
        var id, j, len, ref, results;
        ref = wApp.clipboard.ids();
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
            id = ref[j];
            results.push(wApp.clipboard.subSelect(id));
        }
        return results;
    },
    checkEntityExistence: function() {
        var ids;
        ids = wApp.clipboard.ids().concat(wApp.clipboard.subSelection());
        return Zepto.ajax({
            type: "POST",
            url: "/entities/existence",
            data: JSON.stringify({
                ids: ids
            }),
            success: function(data) {
                var existence, id, results;
                results = [];
                for (id in data) {
                    existence = data[id];
                    if (!existence) {
                        results.push(wApp.clipboard.remove(parseInt(id)));
                    } else {
                        results.push(void 0);
                    }
                }
                return results;
            }
        });
    }
};

wApp.config = {
    setup: function() {
        return Zepto.ajax({
            url: "/settings",
            success: function(data) {
                return wApp.config.data = data;
            }
        });
    },
    hasHelp: function(key) {
        return wApp.config.helpFor(key).length > 0;
    },
    helpFor: function(key) {
        var help;
        help = wApp.config.data.values["help_" + key];
        if (help) {
            return help.trim();
        } else {
            return "";
        }
    },
    showHelp: function(k) {
        return wApp.bus.trigger("modal", "kor-help", {
            key: k
        });
    }
};

wApp.mixins.config = {
    config: function() {
        return wApp.config.data.values;
    }
};

wApp.bus.on("config-updated", wApp.config.setup);

wApp.i18n = {
    setup: function() {
        return Zepto.ajax({
            url: "/translations",
            success: function(data) {
                return wApp.i18n.translations = data.translations;
            }
        });
    },
    locales: function() {
        return Object.keys(wApp.i18n.translations);
    },
    translate: function(locale, input, options) {
        var count, error, j, key, len, part, parts, ref, regex, result, tvalue, value;
        if (options == null) {
            options = {};
        }
        if (!wApp.i18n.translations) {
            return "";
        }
        try {
            options.count || (options.count = 1);
            if (options.warnMissingKey === void 0) {
                options.warnMissingKey = true;
            }
            parts = input.split(".");
            result = wApp.i18n.translations[locale];
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
                tvalue = wApp.i18n.translate(locale, value, {
                    warnMissingKey: false
                });
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
            if (options["warnMissingKey"]) {
                console.warn(error, "for key", input);
            }
            return "";
        }
    },
    localize: function(locale, input, format_name) {
        var date, error, format;
        if (format_name == null) {
            format_name = "date.formats.default";
        }
        try {
            if (!input) {
                return "";
            }
            format = wApp.i18n.translate(locale, format_name);
            date = new Date(input);
            return strftime(format, date);
        } catch (error1) {
            error = error1;
            console.warn(error, "for key", input);
            return "";
        }
    },
    humanSize: function(input) {
        if (input < 1024) {
            return input + " B";
        }
        if (input < 1024 * 1024) {
            return Math.round(input / 1024 * 100) / 100 + " KB";
        }
        if (input < 1024 * 1024 * 1024) {
            return Math.round(input / (1024 * 1024) * 100) / 100 + " MB";
        }
        if (input < 1024 * 1024 * 1024 * 1024) {
            return Math.round(input / (1024 * 1024 * 1024) * 100) / 100 + " GB";
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
    },
    hs: function(input) {
        return wApp.i18n.humanSize(input);
    }
};

wApp.i18n.t = wApp.i18n.translate;

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
    rootUrl: function() {
        return this.info().url;
    }
};

wApp.routing = {
    query: function(params, reset) {
        var base, k, qs, result, v;
        if (reset == null) {
            reset = false;
        }
        if (params) {
            result = {};
            base = reset ? {} : wApp.routing.query();
            Zepto.extend(result, base, params);
            qs = [];
            for (k in result) {
                v = result[k];
                if (result[k] !== null && result[k] !== "") {
                    qs.push(k + "=" + v);
                }
            }
            return route(wApp.routing.path() + "?" + qs.join("&"));
        } else {
            result = wApp.routing.parts()["hash_query"] || {};
            return Zepto.extend({}, result);
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
                        result.hash_query[kv[0]] = decodeURIComponent(kv[1]);
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
        var reload;
        reload = function() {
            return Zepto.ajax({
                method: "get",
                url: "/session",
                success: function(data) {
                    wApp.session.current = data.session;
                    return riot.update();
                }
            });
        };
        wApp.bus.on("reload-session", reload);
        return reload();
    },
    csrfToken: function() {
        return (wApp.session.current || {}).csrfToken;
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
            if (dummy !== void 0) {
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
    toArray: function(value) {
        if (value === null || value === void 0) {
            return [];
        } else {
            if (Zepto.isArray(value)) {
                return value;
            } else {
                return [ value ];
            }
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
    },
    capitalize: function(value) {
        return value.charAt(0).toUpperCase() + value.slice(1);
    },
    confirm: function(string) {
        string || (string = wApp.i18n.t(wApp.session.current.locale, "confirm.sure"));
        return window.confirm(string);
    },
    toIdArray: function(obj) {
        var j, len, o, results;
        if (!obj) {
            return null;
        }
        if (!Zepto.isArray(obj)) {
            obj = obj.split(",");
        }
        results = [];
        for (j = 0, len = obj.length; j < len; j++) {
            o = obj[j];
            results.push(parseInt(o));
        }
        return results;
    },
    listToArray: function(value) {
        var j, len, ref, results, v;
        if (!value) {
            return null;
        }
        ref = value.split(",");
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
            v = ref[j];
            results.push(parseInt(v));
        }
        return results;
    },
    arrayToList: function(values) {
        if (!values) {
            return "";
        }
        return values.join(",");
    },
    isoToDate: function(str) {
        var i, parts;
        parts = function() {
            var j, len, ref, results;
            ref = str.split("-");
            results = [];
            for (j = 0, len = ref.length; j < len; j++) {
                i = ref[j];
                results.push(parseInt(i));
            }
            return results;
        }();
        return new Date(parts[0], parts[1] - 1, parts[2]);
    }
};

wApp.mixins.editor = {
    resource: {
        singular: "unknown-resource",
        plural: "unknown-resources"
    },
    resourceId: function() {
        return tag.opts.id;
    },
    save: function(event) {
        event.preventDefault();
        var p = this.resourceId() ? this.updateRequest() : this.createRequest();
        p.done(this.onSuccess);
        p.fail(this.onError);
        p.always(this.onComplete);
    },
    createRequest: function() {
        var data = {};
        data[this.resource.singular] = this.formValues();
        return Zepto.ajax({
            type: "POST",
            url: "/" + this.resource.plural,
            data: JSON.stringify(data)
        });
    },
    updateRequest: function() {
        var data = {};
        data[this.resource.singular] = this.formValues();
        return Zepto.ajax({
            type: "PATCH",
            url: "/" + this.resource.plural + "/" + this.resourceId(),
            data: JSON.stringify(data)
        });
    },
    onSuccess: function(data) {
        this.errors = {};
        wApp.routing.path("/" + this.resource.plural);
    },
    onError: function(xhr) {
        this.errors = JSON.parse(xhr.responseText).errors;
        wApp.utils.scrollToTop();
    },
    onComplete: function() {
        this.update();
    },
    formValues: function() {
        var results = {};
        for (var i = 0; i < this.refs.fields.length; i++) {
            var f = this.refs.fields[i];
            results[f.name()] = f.value();
        }
        return results;
    }
};

wApp.mixins.form = {
    values: function() {
        var results = {};
        var fields = this.fields();
        for (var i = 0; i < fields.length; i++) {
            var f = fields[i];
            var v = f.value();
            if (v === "" || v === [] || v === undefined) {
                results[f.name()] = null;
            } else {
                results[f.name()] = v;
            }
        }
        return results;
    },
    setValues: function(values, clean) {
        var fields = this.fields();
        for (var i = 0; i < fields.length; i++) {
            var f = fields[i];
            var v = values[f.name()];
            if (v) {
                if (!f.set) {
                    console.log(f);
                }
                f.set(v);
            }
            if (!v && !!clean) {
                f.reset();
            }
        }
    },
    fields: function() {
        var byTag = wApp.utils.toArray(this.tags["kor-input"]).filter(function(i) {
            return i.opts.type != "submit" && i.opts.type != "reset";
        });
        var byRef = wApp.utils.toArray(this.refs["fields"]);
        return byTag.concat(byRef);
    },
    fieldsByName: function() {
        var results = {};
        var fields = this.fields();
        for (var i = 0; i < fields.length; i++) {
            f = fields[i];
            results[f.name()] = f;
        }
        return results;
    }
};

wApp.entityHistory = {
    add: function(id) {
        console.log(id);
        var ids = wApp.entityHistory.ids();
        ids.unshift(id);
        ids = ids.slice(0, 30);
        Lockr.set("entity-history", ids);
    },
    ids: function() {
        return Lockr.get("entity-history") || [];
    },
    reset: function() {
        Lockr.rm("entity-history");
    },
    setup: function() {
        wApp.bus.on("logout", function() {
            wApp.entityHistory.reset();
        });
    }
};

wApp.mixins.page = {
    title: function(newTitle) {
        wApp.bus.trigger("page-title", wApp.utils.capitalize(newTitle));
    }
};

riot.tag2("kor-field-editor", '<h2 if="{opts.id}"> {tcap(\'objects.edit\', {interpolations: {o: \'activerecord.models.field\'}})} </h2> <h2 if="{!opts.id}"> {tcap(\'objects.create\', {interpolations: {o: \'activerecord.models.field\'}})} </h2> <form if="{data && types}" onsubmit="{submit}"> <kor-input name="type" label="{tcap(\'activerecord.attributes.field.type\')}" type="select" options="{types_for_select}" riot-value="{data.type}" is-disabled="{data.id}" ref="fields" onchange="{updateSpecialFields}"></kor-input> <virtual each="{f in specialFields}"> <kor-input name="{f.name}" label="{tcap(\'activerecord.attributes.field.\' + f.name)}" type="{f.type}" options="{f.options}" riot-value="{data[f.name]}" errors="{errors[f.name]}" ref="fields"></kor-input> </virtual> <kor-input name="name" label="{tcap(\'activerecord.attributes.field.name\')}" riot-value="{data.name}" errors="{errors.name}" ref="fields"></kor-input> <kor-input name="show_label" label="{tcap(\'activerecord.attributes.field.show_label\')}" riot-value="{data.show_label}" errors="{errors.show_label}" ref="fields"></kor-input> <kor-input name="form_label" label="{tcap(\'activerecord.attributes.field.form_label\')}" riot-value="{data.form_label}" errors="{errors.form_label}" ref="fields"></kor-input> <kor-input name="search_label" label="{tcap(\'activerecord.attributes.field.search_label\')}" riot-value="{data.search_label}" errors="{errors.search_label}" ref="fields"></kor-input> <kor-input name="show_on_entity" type="checkbox" label="{tcap(\'activerecord.attributes.field.show_on_entity\')}" riot-value="{data.show_on_entity}" ref="fields"></kor-input> <kor-input name="is_identifier" type="checkbox" label="{tcap(\'activerecord.attributes.field.is_identifier\')}" riot-value="{data.is_identifier}" ref="fields"></kor-input> <div class="hr"></div> <kor-input type="submit"></kor-input> </form>', "", "", function(opts) {
    var create, fetch, fetchTypes, tag, update, values;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.errors = {};
    tag.on("mount", function() {
        if (tag.opts.id) {
            fetch();
        } else {
            tag.data = {
                type: "Fields::String"
            };
            tag.update();
        }
        return fetchTypes();
    });
    tag.updateSpecialFields = function(event) {
        var typeName, types;
        typeName = event ? Zepto(event.target).val() : tag.data.type;
        tag.data.type = typeName;
        if (types = tag.types) {
            tag.specialFields = types[typeName].fields;
            return tag.update();
        }
    };
    tag.submit = function(event) {
        var p;
        event.preventDefault();
        p = tag.opts.id ? update() : create();
        p.done(function(data) {
            tag.errors = {};
            tag.opts.notify.trigger("refresh");
            return route("/kinds/" + tag.opts.kindId + "/edit");
        });
        p.fail(function(xhr) {
            tag.errors = JSON.parse(xhr.responseText).errors;
            return wApp.utils.scrollToTop();
        });
        return p.always(function() {
            return tag.update();
        });
    };
    create = function() {
        return Zepto.ajax({
            type: "POST",
            url: "/kinds/" + tag.opts.kindId + "/fields",
            data: JSON.stringify(values())
        });
    };
    update = function() {
        return Zepto.ajax({
            type: "PATCH",
            url: "/kinds/" + tag.opts.kindId + "/fields/" + tag.opts.id,
            data: JSON.stringify(values())
        });
    };
    values = function() {
        var k, ref, results, t;
        results = {};
        ref = tag.refs.fields;
        for (k in ref) {
            t = ref[k];
            results[t.name()] = t.value();
        }
        return {
            field: results,
            klass: results.type
        };
    };
    fetch = function() {
        return Zepto.ajax({
            url: "/kinds/" + tag.opts.kindId + "/fields/" + tag.opts.id,
            success: function(data) {
                tag.data = data;
                tag.update();
                return tag.updateSpecialFields();
            }
        });
    };
    fetchTypes = function() {
        return Zepto.ajax({
            url: "/fields/types",
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
                tag.update();
                return tag.updateSpecialFields();
            }
        });
    };
});

riot.tag2("kor-fields", '<div class="pull-right kor-text-right"> <a href="#/kinds/{opts.kind.id}/edit/fields/new" title="{t(\'verbs.add\')}"> <i class="fa fa-plus-square"></i> </a> </div> <strong> {tcap(\'activerecord.models.field\', {count: \'other\'})} </strong> <div class="clearfix"></div> <ul if="{opts.kind}"> <li each="{field in opts.kind.fields}"> <div class="pull-right kor-text-right"> <a href="#/kinds/{opts.kind.id}/edit/fields/{field.id}/edit" title="{t(\'verbs.edit\')}"><i class="fa fa-edit"></i></a> <a href="#" onclick="{remove(field)}" title="{t(\'verbs.delete\')}"><i class="fa fa-remove"></i></a> </div> <a href="#/kinds/{opts.kind.id}/edit/fields/{field.id}/edit">{field.name}</a> <div class="clearfix"></div> </li> </ul> <div class="clearfix"></div>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.remove = function(field) {
        return function(event) {
            event.preventDefault();
            if (wApp.utils.confirm(wApp.i18n.translate("confirm.general"))) {
                return Zepto.ajax({
                    type: "DELETE",
                    url: "/kinds/" + tag.opts.kind.id + "/fields/" + field.id,
                    success: function() {
                        route("/kinds/" + tag.opts.kind.id + "/edit");
                        return tag.opts.notify.trigger("refresh");
                    }
                });
            }
        };
    };
});

riot.tag2("kor-generator-editor", '<h2 if="{opts.id}"> {tcap(\'objects.edit\', {interpolations: {o: \'activerecord.models.generator\'}})} </h2> <h2 if="{!opts.id}"> {tcap(\'objects.create\', {interpolations: {o: \'activerecord.models.generator\'}})} </h2> <form if="{data}" onsubmit="{submit}"> <kor-input name="name" label="{tcap(\'activerecord.attributes.generator.name\')}" riot-value="{data.name}" errors="{errors.name}" ref="fields"></kor-input> <kor-input name="directive" label="{tcap(\'activerecord.attributes.generator.directive\')}" type="textarea" riot-value="{data.directive}" errors="{errors.directive}" ref="fields"></kor-input> <hr> <kor-input type="submit"></kor-input> </form>', "", "", function(opts) {
    var create, fetch, tag, update, values;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.errors = {};
    tag.on("mount", function() {
        if (tag.opts.id) {
            return fetch();
        } else {
            tag.data = {};
            return tag.update();
        }
    });
    tag.submit = function(event) {
        var p;
        event.preventDefault();
        p = tag.opts.id ? update() : create();
        p.done(function(data) {
            tag.errors = {};
            tag.opts.notify.trigger("refresh");
            return route("/kinds/" + tag.opts.kindId + "/edit");
        });
        p.fail(function(xhr) {
            tag.errors = JSON.parse(xhr.responseText).errors;
            return wApp.utils.scrollToTop();
        });
        return p.always(function() {
            return tag.update();
        });
    };
    create = function() {
        return Zepto.ajax({
            type: "POST",
            url: "/kinds/" + tag.opts.kindId + "/generators",
            data: JSON.stringify(values())
        });
    };
    update = function() {
        return Zepto.ajax({
            type: "PATCH",
            url: "/kinds/" + tag.opts.kindId + "/generators/" + tag.opts.id,
            data: JSON.stringify(values())
        });
    };
    values = function() {
        var k, ref, results, t;
        results = {};
        ref = tag.refs.fields;
        for (k in ref) {
            t = ref[k];
            results[t.name()] = t.value();
        }
        return {
            generator: results
        };
    };
    fetch = function() {
        return Zepto.ajax({
            url: "/kinds/" + tag.opts.kindId + "/generators/" + tag.opts.id,
            success: function(data) {
                tag.data = data;
                return tag.update();
            }
        });
    };
});

riot.tag2("kor-generators", '<div class="pull-right kor-text-right"> <a href="#/kinds/{opts.kind.id}/edit/generators/new" title="{t(\'verbs.add\')}"> <i class="fa fa-plus-square"></i> </a> </div> <strong> {tcap(\'activerecord.models.generator\', {count: \'other\'})} </strong> <div class="clearfix"></div> <ul if="{opts.kind}"> <li each="{generator in opts.kind.generators}"> <div class="pull-right kor-text-right"> <a href="#/kinds/{opts.kind.id}/edit/generators/{generator.id}/edit" title="{t(\'verbs.edit\')}"><i class="fa fa-edit"></i></a> <a href="#/kinds/{opts.kind.id}/edit/generators/{generator.id}" onclick="{remove(generator)}" title="{t(\'verbs.delete\')}"><i class="fa fa-remove"></i></a> </div> <a href="#/kinds/{opts.kind.id}/edit/generators/{generator.id}/edit">{generator.name}</a> <div class="clearfix"></div> </li> </ul> <div class="clearfix"></div>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.remove = function(generator) {
        return function(event) {
            event.preventDefault();
            if (wApp.utils.confirm(wApp.i18n.translate("confirm.general"))) {
                return Zepto.ajax({
                    type: "DELETE",
                    url: "/kinds/" + tag.opts.kind.id + "/generators/" + generator.id,
                    success: function() {
                        route("/kinds/" + tag.opts.kind.id + "/edit");
                        return tag.opts.notify.trigger("refresh");
                    }
                });
            }
        };
    };
});

riot.tag2("kor-loading", "<span>... loading ...</span>", "", "", function(opts) {});

riot.tag2("kor-logout", '<a href="#" onclick="{logout}"> {t(\'verbs.logout\')} </a>', "", 'show="{isLoggedIn()}"', function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.logout = function(event) {
        event.preventDefault();
        return wApp.auth.logout().then(function() {
            wApp.bus.trigger("logout");
            return wApp.bus.trigger("routing:path", wApp.routing.parts());
        });
    };
});

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

riot.tag2("kor-ask-choices", '<div class="kor-content-box" if="{ready()}"> <a href="#" onclick="{all}" title="{t(\'all\')}">{t(\'all\')}</a> | <a href="#" onclick="{none}" title="{t(\'none\')}">{t(\'none\')}</a> <hr> <virtual each="{choice in opts.choices}"> <kor-input label="{choice.name || choice.label}" name="{choice.id || choice.value}" riot-value="{isChecked(choice)}" type="checkbox" ref="choices"></kor-input> <div class="clearfix"></div> </virtual> <hr> <div class="kor-text-right"> <button onclick="{cancel}">{t(\'cancel\')}</button> <button onclick="{ok}">{t(\'ok\')}</button> </div> </div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.on("before-mount", function() {
        fromOpts();
    });
    tag.ok = function(event) {
        var results = tag.value();
        tag.opts.modal.trigger("close");
        if (h = tag.opts.notify) {
            h(results);
        }
    };
    tag.cancel = function(event) {
        tag.opts.modal.trigger("close");
    };
    tag.all = function(event) {
        event.preventDefault();
        tag.ids = [];
        for (var i = 0; i < tag.opts.choices.length; i++) {
            var c = tag.opts.choices[i];
            tag.ids.push(c.id || c.value);
        }
        tag.update();
    };
    tag.none = function(event) {
        event.preventDefault();
        tag.ids = [];
        tag.update();
    };
    tag.ready = function() {
        return Zepto.isArray(tag.ids);
    };
    tag.value = function() {
        if (Zepto.isArray(tag.refs["choices"])) {
            var results = [];
            for (var i = 0; i < tag.refs["choices"].length; i++) {
                var c = tag.refs["choices"][i];
                if (c.value()) {
                    results.push(c.name());
                }
            }
            return results;
        } else {
            return [ tag.refs["choices"].value() ];
        }
    };
    tag.isChecked = function(choice) {
        return tag.ids.indexOf(choice.id || choice.value) > -1;
    };
    var fromOpts = function() {
        tag.ids = tag.opts.riotValue || [];
    };
});

riot.tag2("kor-clipboard-control", '<a onclick="{toggle}" if="{!isGuest()}" href="#/entities/{opts.entity.id}/to_clipboard" class="to-clipboard" title="{t(\'add_to_clipboard\')}"> <i class="fa fa-clipboard {kor-glow: isIncluded()}"></i> </a>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.on("mount", function() {
        return wApp.bus.on("clipboard-changed", tag.update);
    });
    tag.on("unmount", function() {
        return wApp.bus.off("clipboard-changed", tag.update);
    });
    tag.isIncluded = function() {
        return wApp.clipboard.includes(tag.opts.entity.id);
    };
    tag.isSelected = function() {
        return wApp.clipboard.selected(tag.opts.entity.id);
    };
    tag.toggle = function(event) {
        event.preventDefault();
        if (tag.isIncluded()) {
            wApp.clipboard.remove(tag.opts.entity.id);
            wApp.bus.trigger("message", "notice", tag.t("objects.unmarked_entity_success"));
        } else {
            if (wApp.clipboard.ids().length <= 500) {
                wApp.clipboard.add(tag.opts.entity.id);
                wApp.bus.trigger("message", "notice", tag.t("objects.marked_entity_success"));
            } else {
                wApp.bus.trigger("message", "error", tag.t("messages.clipboard_too_many_elements"));
            }
        }
        return tag.update();
    };
    tag.toggleSelection = function(event) {
        event.preventDefault();
        if (!tag.isSelected()) {
            wApp.clipboard.select(tag.opts.entity.id);
            wApp.bus.trigger("message", "notice", tag.t("objects.marked_as_current_success"));
            return tag.update();
        }
    };
});

riot.tag2("kor-clipboard-subselect-control", '<kor-input type="checkbox" riot-value="{checked()}" onchange="{change}"></kor-input>', "", "", function(opts) {
    var tag = this;
    tag.checked = function() {
        return wApp.clipboard.subSelected(tag.opts.entity.id);
    };
    tag.change = function(event) {
        var e = Zepto(event.target);
        var id = tag.opts.entity.id;
        if (e.prop("checked")) {
            wApp.clipboard.subSelect(id);
        } else {
            wApp.clipboard.unSubSelect(id);
        }
    };
});

riot.tag2("kor-collection-selector", '<virtual if="{collections}"> <virtual if="{collections.length == 1}" input ref="input" type="hidden" riot-value="{collections[0].id}"></virtual> </virtual> <virtual if="{collections && collections.length > 1}"> <kor-input if="{!opts.multiple}" label="{tcap(\'activerecord.models.collection\')}" name="{opts.name}" type="select" options="{collections}" ref="input"></kor-input> <virtual if="{opts.multiple}"> <label>{tcap(\'activerecord.models.collection\', {count: \'other\'})}:</label> <strong if="{!ids || ids.length == 0}">{t(\'all\')}</strong> <strong if="{ids && ids.length > 0}">{selectedList()}</strong> <a href="#" onclick="{selectCollections}" title="{t(\'verbs.edit\')}"><i class="fa fa-edit"></i></a> </virtual> </virtual> </virtual>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.on("before-mount", function() {
        tag.reset();
    });
    tag.on("mount", function() {
        fetch();
    });
    tag.reset = function() {
        tag.ids = tag.opts.riotValue || [];
    };
    tag.name = function() {
        return tag.opts.name;
    };
    tag.value = function() {
        if (tag.collections.length == 1) {
            var id = tag.collections[0].id;
            if (tag.opts.multiple) return [ id ]; else return id;
        } else {
            if (tag.opts.multiple) {
                return tag.ids;
            } else {
                return tag.refs["input"].value();
            }
        }
    };
    tag.set = function(value) {
        tag.ids = value || [];
        tag.update();
    };
    tag.selectCollections = function(event) {
        event.preventDefault();
        var cols = allowedCollections();
        var ids = tag.ids || [];
        if (ids.length == 0) {
            for (var i = 0; i < cols.length; i++) {
                ids.push(cols[i].id);
            }
        }
        wApp.bus.trigger("modal", "kor-ask-choices", {
            choices: allowedCollections(),
            multiple: true,
            notify: newSelection,
            riotValue: ids
        });
    };
    tag.selectedList = function() {
        var all = true;
        var results = [];
        for (var i = 0; i < tag.collections.length; i++) {
            var c = tag.collections[i];
            if (tag.ids.indexOf(c.id) != -1) {
                results.push(c.name);
            } else {
                all = false;
            }
        }
        if (all) {
            return tag.t("all");
        } else {
            return results.join(", ");
        }
    };
    var newSelection = function(ids) {
        tag.ids = ids;
        Zepto(tag.root).trigger("change", [ tag.ids ]);
        tag.update();
    };
    var fetch = function() {
        Zepto.ajax({
            url: "/collections",
            success: function(data) {
                tag.collections = data.records;
                tag.update();
            }
        });
    };
    var allowedCollections = function() {
        var allowed = wApp.session.current.user.permissions.collections[tag.opts.policy];
        var results = [];
        for (var i = 0; i < tag.collections.length; i++) {
            var c = tag.collections[i];
            if (allowed.indexOf(c.id) != -1) {
                results.push(c);
            }
        }
        return results;
    };
});

riot.tag2("kor-dataset-fields", '<virtual each="{field in opts.fields}"> <kor-input if="{simple(field)}" name="{field.name}" label="{field.form_label}" riot-value="{values()[field.name]}" ref="fields" errors="{errorsFor(field)}"></kor-input> <kor-input if="{field.type == \'Fields::Text\'}" name="{field.name}" label="{field.form_label}" riot-value="{values()[field.name]}" ref="fields" errors="{errorsFor(field)}" type="textarea"></kor-input> <kor-input if="{field.type == \'Fields::Select\'}" name="{field.name}" label="{field.form_label}" riot-value="{values()[field.name]}" ref="fields" errors="{errorsFor(field)}" type="select" options="{field.values.split(⁗\\n⁗)}" multiple="{field.subtype == \'multiselect\'}"></kor-input> </virtual>', "", "", function(opts) {
    var tag = this;
    tag.errorsFor = function(field) {
        if (tag.opts.errors) {
            return tag.opts.errors[field.name];
        }
    };
    tag.values = function() {
        return opts.values || {};
    };
    tag.set = function(values) {
        var fields = wApp.utils.toArray(tag.refs["fields"]);
        for (var i = 0; i < fields.length; i++) {
            var f = fields[i];
            f.set(values[f.name()]);
        }
    };
    tag.name = function() {
        return tag.opts.name;
    };
    tag.value = function() {
        var result = {};
        var inputs = wApp.utils.toArray(tag.tags["kor-input"]);
        for (var i = 0; i < inputs.length; i++) {
            var field = inputs[i];
            result[field.name()] = field.value();
        }
        return result;
    };
    tag.type = function(field) {
        if (field.type == "Fields::Text") {
            return "textarea";
        }
        return "text";
    };
    tag.simple = function(field) {
        return field.type == "Fields::String" || field.type == "Fields::Isbn" || field.type == "Fields::Regex";
    };
});

riot.tag2("kor-datings-editor", '<div class="header" if="{add}"> <button onclick="{add}" class="pull-right" type="button"> {t(\'verbs.add\', {capitalize: true})} </button> <label>{opts.label || tcap(\'activerecord.models.entity_dating\', {count: \'other\'})}</label> <div class="clearfix"></div> </div> <ul show="{anyVisibleDatings()}"> <li each="{dating, i in data}" show="{!dating._destroy}" visible="{!dating._destroy}" no-reorder> <kor-input label="{t(\'activerecord.attributes.dating.label\', {capitalize: true})}" riot-value="{dating.label}" ref="labels" errors="{errorsFor(i, \'label\')}"></kor-input> <kor-input label="{t(\'activerecord.attributes.dating.dating_string\', {capitalize: true})}" riot-value="{dating.dating_string}" ref="dating_strings" errors="{errorsFor(i, \'dating_string\')}"></kor-input> <div class="kor-text-right"> <button onclick="{remove}"> {t(\'verbs.delete\')} </button> </div> <div class="clearfix"></div> </li> </ul>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.on("mount", function() {
        tag.data = tag.opts.riotValue || [];
        tag.deleted = [];
        return tag.update();
    });
    tag.anyVisibleDatings = function() {
        var dating, j, len, ref;
        ref = tag.data || [];
        for (j = 0, len = ref.length; j < len; j++) {
            dating = ref[j];
            if (!dating["_destroy"]) {
                return true;
            }
        }
        return false;
    };
    tag.name = function() {
        return tag.opts.name;
    };
    tag.errorsFor = function(i, field) {
        var e, o;
        e = tag.opts.errors || [];
        o = e[i] || {};
        return o[field];
    };
    tag.set = function(values) {
        var dating, i, ref, results;
        tag.data = values;
        tag.update();
        ref = tag.data;
        results = [];
        for (i in ref) {
            dating = ref[i];
            results.push(tag.setDating(i, dating));
        }
        return results;
    };
    tag.add = function(event) {
        if (event) {
            event.preventDefault();
        }
        tag.data.push({
            label: tag.opts.defaultDatingLabel
        });
        return tag.update();
    };
    tag.remove = function(event) {
        var dating, index;
        event.preventDefault();
        dating = event.item.dating;
        index = event.item.i;
        if (dating.id) {
            return dating._destroy = true;
        } else {
            return tag.data.splice(index, 1);
        }
    };
    tag.value = function() {
        var dating, datingStringInputs, i, labelInputs, ref;
        labelInputs = wApp.utils.toArray(tag.refs["labels"]);
        datingStringInputs = wApp.utils.toArray(tag.refs["dating_strings"]);
        ref = tag.data;
        for (i in ref) {
            dating = ref[i];
            dating["label"] = labelInputs[i].value();
            dating["dating_string"] = datingStringInputs[i].value();
        }
        return tag.data;
    };
});

riot.tag2("kor-help", '<div class="kor-content-box" ref="target"></div>', "", "", function(opts) {
    var tag = this;
    tag.on("mount", function() {
        var help = wApp.config.helpFor(tag.opts.key);
        Zepto(tag.refs.target).html(help);
    });
});

riot.tag2("kor-mass-relate", '<div class="kor-content-box"> <h1>{tcap(\'clipboard_actions.mass_relate\')}</h1> <div if="{error}" class="error">{tcap(error)}</div> <form onsubmit="{save}" onreset="{cancel}"> <virtual if="{data}"> <kor-relation-selector source-kind-id="{sourceKindId}" target-kind-id="{targetKindId}" errors="{errors.relation_id}" ref="relationName" onchange="{relationChanged}"></kor-relation-selector> <hr> <kor-entity-selector relation-name="{relation_name}" errors="{errors.to_id}" ref="targetId" onchange="{targetChanged}"></kor-entity-selector> <hr> <kor-properties-editor ref="properties"></kor-properties-editor> <hr> <kor-datings-editor ref="datings" errors="{errors.datings}" for="relationship"></kor-datings-editor> <hr> <kor-input type="submit"></kor-input> </virtual> <kor-input type="reset" label="{tcap(\'cancel\')}"></kor-input> </form> </div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.editor);
    tag.on("mount", function() {
        tag.errors = {};
        fetch();
    });
    tag.save = function(event) {
        event.preventDefault();
        Zepto.ajax({
            type: "POST",
            url: "/entities/" + tag.to_id + "/mass_relate",
            data: JSON.stringify({
                entity_ids: tag.opts.ids,
                relation_name: tag.relation_name
            }),
            success: function(data) {
                tag.opts.modal.trigger("close");
            }
        });
    };
    tag.cancel = function() {
        tag.opts.modal.trigger("close");
    };
    tag.relationChanged = function() {
        tag.relation_name = tag.refs.relationName.value();
        tag.update();
        tag.refs.targetId.trigger("reload");
    };
    tag.targetChanged = function() {
        tag.to_id = tag.refs.targetId.value();
        fetchTarget();
    };
    tag.formValues = function() {
        return {
            from_id: tag.from_id,
            relation_name: tag.refs.relationName.value(),
            to_id: tag.refs.targetId.value(),
            properties: tag.refs.properties.value(),
            datings_attributes: tag.refs.datings.value()
        };
    };
    var fetch = function() {
        if (!tag.opts.ids || tag.opts.ids.length < 1) {
            return setError("messages.must_select_1_or_more_entities");
        }
        if (tag.opts.ids.length > 10) {
            return setError("messages.cant_merge_more_than_10_entities");
        }
        Zepto.ajax({
            type: "GET",
            url: "/entities",
            data: {
                id: tag.opts.ids.join(",")
            },
            success: function(data) {
                if (data.total < tag.opts.ids.length) {
                    return setError("messages.missing_entities_to_merge");
                }
                for (var i = 1; i < data.records.length; i++) {
                    var e = data.records[i];
                    if (e.kind_id != data.records[0].kind_id) {
                        return setError("messages.only_same_kind");
                    }
                }
                tag.data = data;
                tag.sourceKindId = [];
                for (var i = 0; i < data.records.length; i++) {
                    tag.sourceKindId.push(data.records[i].kind_id);
                }
                tag.update();
            }
        });
    };
    var fetchTarget = function() {
        if (tag.to_id) {
            Zepto.ajax({
                url: "/entities/" + tag.to_id,
                success: function(data) {
                    tag.targetKindId = data.kind_id;
                    tag.update();
                    tag.refs.relationName.trigger("reload");
                }
            });
        } else {
            tag.targetKindId = null;
            tag.update();
            tag.refs.relationName.trigger("reload");
        }
    };
    var setError = function(error) {
        tag.error = error;
        tag.update();
    };
});

riot.tag2("kor-to-entity-group", '<div class="kor-content-box"> <h1>{title()}</h1> <form onsubmit="{submit}"> <kor-entity-group-selector type="{opts.type}" ref="group"></kor-entity-group-selector> <kor-input type="submit"></kor-input> </form> {opts.type} <a if="{opts.type == \'authority\'}" href="#/groups/categories/admin/new" onclick="{add}">{t(\'create_new\')}</a> <a if="{opts.type == \'user\'}" href="#/groups/user/new" onclick="{add}">{t(\'create_new\')}</a> </div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.title = function() {
        return tag.tcap("clipboard_actions.add_to_" + opts.type + "_group");
    };
    tag.submit = function(event) {
        event.preventDefault();
        Zepto.ajax({
            type: "POST",
            url: "/" + tag.opts.type + "_groups/" + tag.refs.group.value() + "/add",
            data: JSON.stringify({
                entity_ids: tag.opts.entityIds
            }),
            success: function(data) {
                tag.opts.modal.trigger("close");
            }
        });
    };
});

riot.tag2("kor-entity", '<virtual if="{isMedium()}"> <kor-clipboard-control if="{!opts.noClipboard}" entity="{opts.entity}"></kor-clipboard-control> <a href="#/entities/{opts.entity.id}" class="to-medium"> <img riot-src="{imageUrl()}"> </a> <div if="{!opts.noContentType}"> {tcap(\'nouns.content_type\')}: <span class="content-type">{opts.entity.medium.content_type}</span> </div> </virtual> <virtual if="{!isMedium()}"> <a class="name" href="#/entities/{opts.entity.id}">{opts.entity.display_name}</a> <span class="kind">{opts.entity.kind_name}</span> </virtual>', "", 'class="{medium: isMedium()}"', function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.info);
    tag.isMedium = function() {
        return tag.opts.entity && !!tag.opts.entity.medium_id;
    };
    tag.imageUrl = function() {
        var base = opts.entity.medium.url.thumbnail;
        if (tag.opts.publishment) {
            return base.replace(/\?([0-9]+)$/, "?uuid=" + tag.opts.publishment + "&$1");
        } else {
            return base;
        }
    };
});

riot.tag2("kor-entity-group-selector", '<kor-input if="{groups}" label="{tcap(\'activerecord.models.\' + opts.type + \'_group\')}" name="{opts.id}" type="select" ref="input" options="{groups}" riot-value="{opts.riotValue}" errors="{opts.errors}"></kor-input>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.on("mount", function() {
        Zepto.ajax({
            url: "/" + tag.opts.type + "_groups",
            data: {
                include: "directory"
            },
            success: function(data) {
                tag.groups = data.records;
                for (var i = 0; i < data.records.length; i++) {
                    var r = data.records[i];
                    if (r.directory) {
                        var names = [];
                        var containers = [ r.directory ].concat(r.directory.ancestors);
                        for (var j = 0; j < containers.length; j++) {
                            var a = containers[j];
                            names.push(a.name);
                        }
                        names.push(r.name);
                        r.name = names.join(" » ");
                    }
                }
                if (tag.opts.riotValue) {
                    tag.groups.unshift({
                        name: tag.tcap("objects.create_group", {
                            interpolations: {
                                o: tag.opts.riotValue
                            }
                        }),
                        value: tag.opts.riotValue
                    });
                }
                console.log(tag.groups[0]);
                tag.update();
            }
        });
    });
    tag.name = function() {
        return tag.opts.name;
    };
    tag.value = function() {
        return tag.refs["input"].value();
    };
});

riot.tag2("kor-entity-merger", '<div class="kor-content-box"> <h1>{tcap(\'verbs.merge\')}</h1> <div if="{error}" class="error">{tcap(error)}</div> <form if="{data}" onsubmit="{submit}"> <kor-input name="uuid" label="{tcap(\'activerecord.attributes.entity.uuid\')}" type="select" options="{combined.uuid}" ref="fields"></kor-input> <kor-input name="subtype" label="{tcap(\'activerecord.attributes.entity.subtype\')}" type="select" options="{combined.subtype}" ref="fields"></kor-input> <kor-collection-selector label="{tcap(\'activerecord.attributes.entity.collection_id\')}"></kor-collection-selector> <kor-input label="{tcap(\'activerecord.attributes.entity.name\')}" name="no_name_statement" type="radio" ref="fields" options="{noNameStatements}"></kor-input> <kor-input name="name" label="{tcap(\'activerecord.attributes.entity.name\')}" type="select" options="{combined.name}" ref="fields"></kor-input> <kor-input name="distinct_name" label="{tcap(\'activerecord.attributes.entity.distinct_name\')}" type="select" options="{combined.distinct_name}" ref="fields"></kor-input> <kor-input if="combined.medium_id.length > 0" label="{tcap(\'activerecord.models.medium\')}" name="medium_id" type="radio" options="{media}" riot-value="{combined.medium_id[0]}" ref="fields"></kor-input> <kor-input if="{combined.comment.length > 0}" name="comment" label="{tcap(\'activerecord.attributes.entity.comment\')}" type="radio" options="{combined.comment}" ref="fields"></kor-input> <kor-input name="tag_list" label="{tcap(\'activerecord.attributes.entity.tag_list\')}" riot-value="{combined.tags.join(\', \')}" ref="fields"></kor-input> <kor-synonyms-editor label="{tcap(\'activerecord.attributes.entity.synonyms\')}" name="synonyms" ref="fields" riot-value="{combined.synonyms}"></kor-synonyms-editor> <hr> <kor-input each="{values, key in combined.dataset}" label="{fieldByKey(key).form_label}" name="{key}" type="select" options="{values}" ref="dataset"></kor-input> <hr> <kor-datings-editor if="{kind}" label="{tcap(\'activerecord.models.entity_dating\', {count: \'other\'})}" name="datings_attributes" ref="fields" riot-value="{combined.datings}" for="entity" kind="{kind}"></kor-datings-editor> <hr> <kor-entity-properties-editor label="{tcap(\'activerecord.attributes.entity.properties\')}" name="properties" ref="fields" riot-value="{combined.properties}"></kor-entity-properties-editor> <hr> <kor-input type="submit"></kor-input> </form> </div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.noNameStatements = [ {
        label: tag.t("values.no_name_statements.unknown"),
        value: "unknown"
    }, {
        label: tag.t("values.no_name_statements.not_available"),
        value: "not_available"
    }, {
        label: tag.t("values.no_name_statements.empty_name"),
        value: "empty_name"
    }, {
        label: tag.t("values.no_name_statements.enter_name"),
        value: "enter_name"
    } ];
    tag.on("mount", function() {
        fetch();
        tag.update();
    });
    tag.submit = function(event) {
        event.preventDefault();
        Zepto.ajax({
            type: "POST",
            url: "/entities/merge",
            data: JSON.stringify({
                entity_ids: tag.combined.id,
                entity: Zepto.extend(values())
            }),
            success: function(data) {
                tag.opts.modal.trigger("close");
                wApp.routing.path("/entities/" + data.id);
            }
        });
    };
    tag.fieldByKey = function(key) {
        for (var i = 0; i < tag.kind.fields.length; i++) {
            var f = tag.kind.fields[i];
            if (f.name == key) {
                return f;
            }
        }
    };
    var fetch = function() {
        if (!tag.opts.ids || tag.opts.ids.length < 2) {
            return setError("messages.must_select_2_or_more_entities");
        }
        if (tag.opts.ids.length > 10) {
            return setError("messages.cant_merge_more_than_10_entities");
        }
        Zepto.ajax({
            type: "GET",
            url: "/entities",
            data: {
                id: tag.opts.ids.join(","),
                include: "all"
            },
            success: function(data) {
                if (data.total < tag.opts.ids.length) {
                    return setError("messages.missing_entities_to_merge");
                }
                for (var i = 1; i < data.records.length; i++) {
                    var e = data.records[i];
                    if (e.kind_id != data.records[0].kind_id) {
                        return setError("messages.only_same_kind");
                    }
                }
                tag.data = data;
                fetchKind(tag.data.records[0].kind_id);
            }
        });
    };
    var fetchKind = function(id) {
        Zepto.ajax({
            type: "GET",
            url: "/kinds/" + id,
            data: {
                include: "fields,settings"
            },
            success: function(data) {
                tag.kind = data;
                combineData();
            }
        });
    };
    var combineData = function() {
        var media = [];
        var combined = {
            id: [],
            uuid: [],
            subtype: [],
            collection_id: [],
            name: [],
            distinct_name: [],
            medium_id: [],
            comment: [],
            tags: [],
            synonyms: [],
            datings: [],
            properties: [],
            dataset: {}
        };
        for (var i = 0; i < tag.data.records.length; i++) {
            var e = tag.data.records[i];
            combined.id.push(e.id);
            combined.uuid.push(e.uuid);
            combined.subtype.push(e.subtype);
            combined.collection_id.push(e.collection_id);
            combined.name.push(e.name);
            combined.distinct_name.push(e.distinct_name);
            if (e.medium_id) {
                combined.medium_id.push(e.medium_id);
                media.push({
                    image_url: e.medium.url.thumbnail,
                    value: e.id
                });
            }
            combined.comment.push(e.comment);
            combined.tags = combined.tags.concat(e.tags);
            combined.datings = combined.datings.concat(e.datings);
            combined.synonyms = combined.synonyms.concat(e.synonyms);
            combined.properties = combined.properties.concat(e.properties);
            for (k in e.dataset) {
                if (!combined.dataset[k]) {
                    combined.dataset[k] = [];
                }
                combined.dataset[k].push(e.dataset[k]);
            }
        }
        combined = cleanup(combined);
        tag.combined = combined;
        tag.media = media;
        tag.update();
    };
    var cleanup = function(values) {
        if (Zepto.isArray(values)) {
            if (values.length == 0) return [];
            if (Zepto.isPlainObject(values[0])) return values;
            var result = wApp.utils.uniq(values).filter(function(e) {
                return e != null && e != "";
            });
            return result.sort();
        } else {
            for (var k in values) {
                values[k] = cleanup(values[k]);
            }
        }
        return values;
    };
    var values = function() {
        var results = {
            dataset: {}
        };
        for (var i = 0; i < tag.refs.fields.length; i++) {
            var korInput = tag.refs.fields[i];
            results[korInput.name()] = korInput.value();
        }
        var df = tag.refs.dataset;
        if (df) {
            if (!Zepto.isArray(df)) {
                df = [ df ];
            }
            for (var i = 0; i < df.length; i++) {
                var korInput = df[i];
                results.dataset[korInput.name()] = korInput.value();
            }
        }
        return results;
    };
    var setError = function(error) {
        tag.error = error;
        tag.update();
    };
});

riot.tag2("kor-entity-properties-editor", '<kor-input label="{opts.label}" type="textarea" riot-value="{valueFromParent()}"></kor-input>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.valueFromParent = function() {
        var i, len, p, ref, results;
        results = [];
        if (opts.riotValue) {
            ref = opts.riotValue;
            for (i = 0, len = ref.length; i < len; i++) {
                p = ref[i];
                results.push(p.label + ": " + p.value);
            }
        }
        return results.join("\n");
    };
    tag.name = function() {
        return tag.opts.name;
    };
    tag.value = function() {
        var i, kv, len, line, ref, results, text;
        text = tag.tags["kor-input"].value();
        if (text.match(/^\s*$/)) {
            return [];
        }
        results = [];
        ref = text.split(/\n/);
        for (i = 0, len = ref.length; i < len; i++) {
            line = ref[i];
            kv = line.split(/:/);
            results.push({
                label: kv.shift().trim(),
                value: kv.join(":").trim()
            });
        }
        return results;
    };
});

riot.tag2("kor-entity-selector", '<div class="pull-right"> <a href="#" onclick="{gotoTab(\'search\')}" class="{\'selected\': currentTab == \'search\'}">{t(\'nouns.search\')}</a> | <a href="#" onclick="{gotoTab(\'visited\')}" class="{\'selected\': currentTab == \'visited\'}">{t(\'recently_visited\')}</a> | <a href="#" onclick="{gotoTab(\'created\')}" class="{\'selected\': currentTab == \'created\'}">{t(\'recently_created\')}</a> <virtual if="{existing}"> | <a href="#" onclick="{gotoTab(\'current\')}" class="{\'selected\': currentTab == \'current\'}">{t(\'currently_linked\')}</a> </virtual> </div> <div class="header"> <label>{opts.label || tcap(\'activerecord.models.entity\')}</label> </div> <kor-input if="{currentTab == \'search\'}" name="terms" placeholder="{tcap(\'nouns.term\')}" ref="terms" onkeyup="{search}"></kor-input> <kor-pagination if="{data}" page="{page}" per-page="{9}" total="{data.total}" on-paginate="{paginate}"></kor-pagination> <table if="{!!groupedEntities}"> <tbody> <tr each="{row in groupedEntities}"> <td each="{record in row}" onclick="{select}" class="{selected: isSelected(record)}"> <kor-entity if="{record}" entity="{record}"></kor-entity> </td> </tr> </tbody> </table> <div class="errors" if="{opts.errors}"> <div each="{e in opts.errors}">{e}</div> </div>', "", "", function(opts) {
    var fetch, group, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.page = 1;
    tag.on("before-mount", function() {
        tag.id = tag.opts.riotValue;
        if (tag.id) {
            tag.existing = true;
        }
        tag.currentTab = tag.id ? "current" : "search";
        tag.trigger("reload");
        return tag.update();
    });
    tag.on("reload", function() {
        return fetch();
    });
    tag.gotoTab = function(newTab) {
        return function(event) {
            event.preventDefault();
            if (tag.currentTab !== newTab) {
                tag.currentTab = newTab;
                tag.data = {};
                tag.groupedEntities = [];
                fetch();
                return tag.update();
            }
        };
    };
    tag.isSelected = function(record) {
        return record && tag.id === record.id;
    };
    tag.select = function(event) {
        var h, record;
        event.preventDefault();
        record = event.item.record;
        if (tag.isSelected(record)) {
            tag.id = void 0;
        } else {
            tag.id = record.id;
        }
        if (h = tag.opts.onchange) {
            return h();
        }
    };
    tag.search = function() {
        if (tag.to) {
            window.clearTimeout(tag.to);
        }
        return tag.to = window.setTimeout(fetch, 300);
    };
    tag.paginate = function(newPage) {
        tag.page = newPage;
        return fetch();
    };
    tag.value = function() {
        return tag.id;
    };
    fetch = function() {
        switch (tag.currentTab) {
          case "current":
            if (tag.opts.riotValue) {
                return Zepto.ajax({
                    url: "/entities/" + tag.opts.riotValue,
                    success: function(data) {
                        tag.data = {
                            records: [ data ]
                        };
                        return group();
                    }
                });
            }
            break;

          case "visited":
            return Zepto.ajax({
                url: "/entities",
                data: {
                    id: wApp.entityHistory.ids(),
                    relation_name: tag.opts.relationName,
                    page: tag.page,
                    per_page: 9
                },
                success: function(data) {
                    tag.data = data;
                    return group();
                }
            });

          case "created":
            return Zepto.ajax({
                url: "/entities",
                data: {
                    relation_name: tag.opts.relationName,
                    page: tag.page,
                    per_page: 9,
                    sort: "created_at",
                    direction: "desc"
                },
                success: function(data) {
                    tag.data = data;
                    return group();
                }
            });

          case "search":
            if (tag.refs.terms) {
                return Zepto.ajax({
                    url: "/entities",
                    data: {
                        terms: tag.refs.terms.value(),
                        relation_name: tag.opts.relationName,
                        per_page: 9,
                        page: tag.page
                    },
                    success: function(data) {
                        tag.data = data;
                        return group();
                    }
                });
            }
        }
    };
    group = function() {
        tag.groupedEntities = wApp.utils.inGroupsOf(3, tag.data.records, null);
        return tag.update();
    };
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

riot.tag2("kor-gallery-grid", '<table> <tbody> <tr each="{row in inGroupsOf(4, opts.entities, false)}"> <td each="{entity in row}"> <virtual if="{entity && entity.medium}"> <kor-entity entity="{entity}" publishment="{opts.publishment}"></kor-entity> <div class="meta" if="{entity.primary_entities}"> <div class="hr"></div> <div class="name"> <a each="{e in secondaries(entity)}" href="#/entities/{e.id}">{e.display_name}</a> </div> <div class="desc"> <a each="{e in primaries(entity)}" href="#/entities/{e.id}">{e.display_name}</a> </div> </div> </virtual> <div class="meta" if="{entity && !entity.medium}"> <div class="name"> <a href="#/entities/{entity.id}">{entity.display_name}</a> </div> <div class="desc">{entity.kind.name}</div> </div> </td> </tr> </tbody> </table>', "", "", function(opts) {
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

riot.tag2("kor-generator", "", "", "", function(opts) {
    var render, tag, update;
    tag = this;
    update = function() {
        var data, e, tpl;
        try {
            tpl = tag.opts.generator.directive;
            data = {
                entity: tag.opts.entity
            };
            return Zepto(tag.root).html(render(tpl, data));
        } catch (error) {
            e = error;
        }
    };
    tag.on("mount", update);
    tag.on("updated", update);
    render = ejs.render;
});

riot.tag2("kor-help-button", '<a if="{hasHelp()}" href="#" onclick="{click}" title="{t(\'nouns.help\')}"><i class="fa fa-question-circle fa-2x"></i></a>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.click = function(event) {
        event.preventDefault();
        wApp.config.showHelp(tag.opts.key);
    };
    tag.hasHelp = function() {
        return wApp.config.hasHelp(tag.opts.key);
    };
});

riot.tag2("kor-inplace-tags", '<virtual if="{opts.entity.tags.length > 0 || opts.enableEditor}"> <span class="field"> {tcap(\'activerecord.models.tag\', {count: \'other\'})}: </span> <span class="value">{opts.entity.tags.join(\', \')}</span> </virtual> <virtual if="{opts.enableEditor}"> <a show="{!editorActive}" onclick="{toggleEditor}" href="#" title="{t(\'edit_tags\')}"><i class="fa fa-plus-square"></i></a> <virtual if="{editorActive}"> <kor-input name="tags" ref="field"></kor-input> <button onclick="{save}">{tcap(\'verbs.save\')}</button> <button onclick="{cancel}">{tcap(\'cancel\')}</button> </virtual> </virtual>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.toggleEditor = function(event) {
        if (event) {
            event.preventDefault();
        }
        return tag.editorActive = !tag.editorActive;
    };
    tag.save = function(event) {
        event.preventDefault();
        return Zepto.ajax({
            type: "PATCH",
            url: "/entities/" + tag.opts.entity.id + "/update_tags",
            data: JSON.stringify({
                entity: {
                    tags: tag.refs.field.value()
                }
            }),
            success: function(data) {
                var h;
                tag.toggleEditor();
                tag.update();
                if (h = tag.opts.handlers.doneHandler) {
                    return h();
                }
            }
        });
    };
    tag.cancel = function(event) {
        event.preventDefault();
        return tag.editorActive = false;
    };
});

riot.tag2("kor-input", '<label if="{opts.type != \'radio\' && opts.type != \'submit\' && opts.type != \'reset\'}"> <span show="{!opts.hideLabel}">{opts.label}</span> <a if="{opts.help}" href="#" onclick="{toggleHelp}"><i class="fa fa-question-circle"></i></a> <input if="{opts.type != \'select\' && opts.type != \'textarea\'}" type="{opts.type || \'text\'}" name="{opts.name}" riot-value="{valueFromParent()}" checked="{checkedFromParent()}" placeholder="{opts.placeholder}"> <textarea if="{opts.type == \'textarea\'}" name="{opts.name}" riot-value="{valueFromParent()}"></textarea> <select if="{opts.type == \'select\'}" name="{opts.name}" riot-value="{valueFromParent()}" multiple="{opts.multiple}" disabled="{opts.isDisabled}"> <option if="{opts.placeholder}" riot-value="{0}">{opts.placeholder}</option> <option each="{item in opts.options}" riot-value="{item.id || item.value || item}" selected="{selected(item)}">{item.name || item.label || item}</option> </select> </label> <input if="{opts.type == \'submit\'}" type="submit" riot-value="{opts.label || tcap(\'verbs.save\')}"> <input if="{opts.type == \'reset\'}" type="reset" riot-value="{opts.label || tcap(\'verbs.reset\')}"> <virtual if="{opts.type == \'radio\'}"> <label>{opts.label}</label> <label class="radio" each="{item in opts.options}"> <input type="radio" name="{opts.name}" riot-value="{item.id || item.value || item}" checked="{valueFromParent() == (item.id || item.value || item)}"> <virtual if="{!item.image_url}">{item.name || item.label || item}</virtual> <img if="{item.image_url}" riot-src="{item.image_url}"> </label> </virtual> <div class="errors" if="{opts.errors}"> <div each="{e in opts.errors}"> {e} </div> </div> <div if="{opts.help && showHelp}" class="help" ref="help"></div>', "", "class=\"{'has-errors': opts.errors}\"", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.on("mount", function() {
        if (tag.opts.autofocus) {
            return Zepto(tag.root).find("input, textarea, select").focus();
        }
    });
    tag.name = function() {
        return tag.opts.name;
    };
    tag.value = function() {
        var i, input, j, len, ref, result;
        if (tag.opts.type === "checkbox") {
            return Zepto(tag.root).find("input").prop("checked");
        } else if (tag.opts.type === "radio") {
            ref = Zepto(tag.root).find("input");
            for (j = 0, len = ref.length; j < len; j++) {
                input = ref[j];
                if ((i = $(input)).prop("checked")) {
                    return i.attr("value");
                }
            }
        } else if (tag.opts.type === "submit") {
            return null;
        } else {
            result = Zepto(tag.root).find("input, select, textarea").val();
            if (result === "0" && tag.opts.type === "select") {
                return void 0;
            } else {
                return result;
            }
        }
    };
    tag.valueFromParent = function() {
        if (tag.opts.type === "checkbox") {
            return 1;
        } else {
            return tag.opts.riotValue;
        }
    };
    tag.checkedFromParent = function() {
        return tag.opts.type === "checkbox" && tag.opts.riotValue;
    };
    tag.checked = function() {
        return tag.opts.type === "checkbox" && Zepto(tag.root).find("input").prop("checked");
    };
    tag.set = function(value) {
        var e, i, input, j, k, len, len1, ref, results, results1, v;
        if (tag.opts.type === "checkbox") {
            return Zepto(tag.root).find("input").prop("checked", !!value);
        } else if (tag.opts.type === "radio") {
            ref = Zepto(tag.root).find("input");
            results = [];
            for (j = 0, len = ref.length; j < len; j++) {
                input = ref[j];
                if ((i = $(input)).attr("value") === value) {
                    results.push(i.prop("checked", true));
                } else {
                    results.push(i.prop("checked", false));
                }
            }
            return results;
        } else if (tag.opts.type === "submit") {} else if (tag.opts.type === "select" && Zepto.isArray(value)) {
            e = Zepto(tag.root).find("select");
            e.val([]);
            results1 = [];
            for (k = 0, len1 = value.length; k < len1; k++) {
                v = value[k];
                e.find("option[value='" + v + "']").prop("selected", true);
                results1.push(Zepto(tag.root).find("select"));
            }
            return results1;
        } else {
            return Zepto(tag.root).find("input, select, textarea").val(value);
        }
    };
    tag.reset = function() {
        return tag.set(tag.valueFromParent());
    };
    tag.selected = function(item) {
        var v;
        v = item.id || item.value || item;
        if (tag.opts.multiple) {
            return (tag.valueFromParent() || []).indexOf(v) > -1;
        } else {
            return "" + v === "" + tag.valueFromParent();
        }
    };
    tag.toggleHelp = function(event) {
        event.preventDefault();
        tag.showHelp = !tag.showHelp;
        tag.update();
        if (tag.showHelp) {
            return Zepto(tag.refs.help).html(tag.opts.help);
        }
    };
});

riot.tag2("kor-kind-selector", '<kor-input if="{kinds}" label="{tcap(\'activerecord.models.kind\')}" type="select" ref="input" options="{kinds}" placeholder="{t(\'all\')}"></kor-input> </kor-input>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.on("mount", function() {
        fetch();
    });
    tag.name = function() {
        return tag.opts.name;
    };
    tag.value = function() {
        var v = tag.refs.input.value();
        if (v) {
            return parseInt(v);
        } else {
            return v;
        }
    };
    tag.set = function(value) {
        if (tag.refs.input) {
            tag.refs.input.set(value);
        } else {
            tag.kind_id = value;
        }
    };
    tag.reset = function() {
        tag.set(null);
    };
    var fetch = function() {
        Zepto.ajax({
            url: "/kinds",
            success: function(data) {
                var results = [];
                for (var i = 0; i < data.records.length; i++) {
                    var k = data.records[i];
                    if (tag.opts.includeMedia || k.id != wApp.info.data.medium_kind_id) {
                        results.push(k);
                    }
                }
                tag.kinds = results;
                tag.update();
                if (tag.kind_id) {
                    tag.refs.input.set(tag.kind_id);
                    tag.kind_id = null;
                }
            }
        });
    };
});

riot.tag2("kor-loading", '<img show="{ajaxInProgress()}" src="/images/loading.gif">', "", "", function(opts) {
    var tag = this;
    tag.on("mount", function() {
        wApp.bus.on("ajax-state-changed", tag.update);
    });
    tag.off("mount", function() {
        wApp.bus.off("ajax-state-changed", tag.update);
    });
    tag.ajaxInProgress = function() {
        return wApp.state.requests.length > 0;
    };
});

riot.tag2("kor-login-info", '<div class="item"> <span class="kor-shine">ConedaKOR</span> {t(\'nouns.version\')} <span class="kor-shine">{info().version}</span> </div> <div class="item"> {tcap(\'provided_by\')}<br> <span class="kor-shine">{info().operator}</span> </div> <div class="item"> {tcap(\'nouns.license\')}<br> <a href="http://www.gnu.org/licenses/agpl-3.0.txt" target="_blank"> {t(\'nouns.agpl\')} </a> </div> <div class="item"> » <a href="{info().source_code_url}" target="_blank"> {t(\'objects.download\', {interpolations: {o: \'nouns.source_code\'}})} </a> </div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.info);
});

riot.tag2("kor-logo", '<?xml version="1.0" encoding="UTF-8" standalone="no"?> <?xml version="1.0" encoding="UTF-8" standalone="no"?> <svg xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape" width="51.114326mm" height="35.500031mm" viewbox="0 0 51.114326 35.500031" version="1.1" id="svg8" sodipodi:docname="logo.svg" inkscape:version="1.0.1 (3bc2e813f5, 2020-09-07)"> <defs id="defs2"></defs> <sodipodi:namedview id="base" pagecolor="#ffffff" bordercolor="#666666" borderopacity="1.0" inkscape:pageopacity="0.0" inkscape:pageshadow="2" inkscape:zoom="7.06159" inkscape:cx="106.4579" inkscape:cy="60.595407" inkscape:document-units="mm" inkscape:current-layer="layer1" inkscape:document-rotation="0" showgrid="false" fit-margin-top="0" fit-margin-left="0" fit-margin-right="0" fit-margin-bottom="0" inkscape:showpageshadow="true" inkscape:window-width="2560" inkscape:window-height="1373" inkscape:window-x="0" inkscape:window-y="0" inkscape:window-maximized="1" /> <metadata id="metadata5"> <rdf:RDF> <cc:Work rdf:about=""> <dc:format>image/svg+xml</dc:format> <dc:type rdf:resource="http://purl.org/dc/dcmitype/StillImage" /> <dc:title></dc:title> </cc:Work> </rdf:RDF> </metadata> <g inkscape:label="Layer 1" inkscape:groupmode="layer" id="layer1" transform="translate(-57.804942,-140.95502)" class="fg"> <path d="m 99.919204,142.95509 c 0,1.10476 -0.89535,2.00022 -1.999897,2.00022 -1.104548,0 -2.00025,-0.89546 -2.00025,-2.00022 0,-1.10451 0.895702,-2.00007 2.00025,-2.00007 1.104547,0 1.999897,0.89556 1.999897,2.00007" style="stroke-width:0.0352778;stroke:none;fill-rule:nonzero;fill-opacity:1;" id="path863" mask="none"></path> <path d="m 99.919204,147.45506 c 0,1.10479 -0.89535,2.00021 -1.999897,2.00021 -1.104548,0 -2.00025,-0.89542 -2.00025,-2.00021 0,-1.10448 0.895702,-1.99994 2.00025,-1.99994 1.104547,0 1.999897,0.89546 1.999897,1.99994" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path865"></path> <path d="m 99.919204,151.95506 c 0,1.10475 -0.89535,2.00021 -1.999897,2.00021 -1.104548,0 -2.00025,-0.89546 -2.00025,-2.00021 0,-1.10452 0.895702,-1.99997 2.00025,-1.99997 1.104547,0 1.999897,0.89545 1.999897,1.99997" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path867"></path> <path d="m 99.919204,156.45502 c 0,1.10479 -0.89535,2.00025 -1.999897,2.00025 -1.104548,0 -2.00025,-0.89546 -2.00025,-2.00025 0,-1.10448 0.895702,-1.99979 2.00025,-1.99979 1.104547,0 1.999897,0.89531 1.999897,1.99979" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path869"></path> <path d="m 108.91927,156.45502 c 0,1.10479 -0.89535,2.00025 -1.9999,2.00025 -1.10454,0 -2.00025,-0.89546 -2.00025,-2.00025 0,-1.10448 0.89571,-1.99979 2.00025,-1.99979 1.10455,0 1.9999,0.89531 1.9999,1.99979" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path871"></path> <path d="m 99.919204,160.95502 c 0,1.10476 -0.89535,2.00021 -1.999897,2.00021 -1.104548,0 -2.00025,-0.89545 -2.00025,-2.00021 0,-1.10452 0.895702,-1.99997 2.00025,-1.99997 1.104547,0 1.999897,0.89545 1.999897,1.99997" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path873"></path> <path d="m 104.41924,160.95502 c 0,1.10476 -0.89535,2.00021 -1.9999,2.00021 -1.10455,0 -2.00025,-0.89545 -2.00025,-2.00021 0,-1.10452 0.8957,-1.99997 2.00025,-1.99997 1.10455,0 1.9999,0.89545 1.9999,1.99997" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path875"></path> <path d="m 99.919204,165.45498 c 0,1.10493 -0.89535,2.00025 -1.999897,2.00025 -1.104548,0 -2.00025,-0.89532 -2.00025,-2.00025 0,-1.10448 0.895702,-1.99993 2.00025,-1.99993 1.104547,0 1.999897,0.89545 1.999897,1.99993" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path877"></path> <path d="m 99.919204,169.95498 c 0,1.10476 -0.89535,2.00021 -1.999897,2.00021 -1.104548,0 -2.00025,-0.89545 -2.00025,-2.00021 0,-1.10451 0.895702,-1.99993 2.00025,-1.99993 1.104547,0 1.999897,0.89542 1.999897,1.99993" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path879"></path> <path d="m 104.41924,169.95498 c 0,1.10476 -0.89535,2.00021 -1.9999,2.00021 -1.10455,0 -2.00025,-0.89545 -2.00025,-2.00021 0,-1.10451 0.8957,-1.99993 2.00025,-1.99993 1.10455,0 1.9999,0.89542 1.9999,1.99993" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path881"></path> <path d="m 99.919204,174.45497 c 0,1.10477 -0.89535,2.00008 -1.999897,2.00008 -1.104548,0 -2.00025,-0.89531 -2.00025,-2.00008 0,-1.1045 0.895702,-1.99996 2.00025,-1.99996 1.104547,0 1.999897,0.89546 1.999897,1.99996" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path883"></path> <path d="m 108.91927,174.45497 c 0,1.10477 -0.89535,2.00008 -1.9999,2.00008 -1.10454,0 -2.00025,-0.89531 -2.00025,-2.00008 0,-1.1045 0.89571,-1.99996 2.00025,-1.99996 1.10455,0 1.9999,0.89546 1.9999,1.99996" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path885"></path> <path d="M 89.090548,176.45505 V 140.95502" style="stroke:#231f20;stroke-width:0.174066;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" id="path887"></path> <path d="m 59.654271,147.65723 h -0.09536 c -0.962974,0 -1.753969,-0.78136 -1.753969,-1.74501 v -3.21264 c 0,-0.97247 0.790995,-1.74456 1.753969,-1.74456 h 0.09536 c 0.886767,0 1.610925,0.64805 1.725299,1.49694 v 0.0285 c 0,0.13342 -0.104726,0.23812 -0.228748,0.23812 -0.114378,0 -0.219111,-0.0854 -0.238404,-0.19981 -0.08544,-0.62011 -0.60978,-1.09665 -1.258147,-1.09665 h -0.09536 c -0.705281,0 -1.286814,0.57189 -1.286814,1.27745 v 3.21264 c 0,0.70594 0.581533,1.27783 1.286814,1.27783 h 0.09536 c 0.648367,0 1.172711,-0.47664 1.258147,-1.09664 0.01929,-0.11438 0.124026,-0.19982 0.238404,-0.19982 0.124022,0 0.228748,0.10474 0.228748,0.23788 v 0.0289 c -0.114374,0.84846 -0.838532,1.49683 -1.725299,1.49683" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path889"></path> <path d="m 65.361408,142.69958 c 0,-0.70556 -0.57217,-1.27745 -1.277443,-1.27745 h -0.09578 c -0.705273,0 -1.277408,0.57189 -1.277408,1.27745 v 3.21264 c 0,0.70594 0.572135,1.27783 1.277408,1.27783 h 0.09578 c 0.705273,0 1.277443,-0.57189 1.277443,-1.27783 z m -1.277443,4.95765 h -0.09578 c -0.962554,0 -1.744592,-0.78136 -1.744592,-1.74501 v -3.21264 c 0,-0.97247 0.782038,-1.74456 1.744592,-1.74456 h 0.09578 c 0.962554,0 1.744345,0.77209 1.744345,1.74456 v 3.21264 c 0,0.96365 -0.781791,1.74501 -1.744345,1.74501" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path891"></path> <path d="m 70.316843,147.65723 h -0.171556 c -0.06685,0 -0.190853,-0.0474 -0.238407,-0.16178 l -2.469445,-5.60642 v 5.52994 c 0,0.16245 -0.124037,0.23826 -0.237984,0.23826 -0.11437,0 -0.23883,-0.0758 -0.23883,-0.23826 v -6.22586 c 0,-0.12379 0.114652,-0.23809 0.23883,-0.23809 h 0.171133 c 0.05719,0 0.162348,0.048 0.210149,0.15275 l 2.488072,5.61513 v -5.52979 c 0,-0.16189 0.124001,-0.23809 0.238407,-0.23809 0.11437,0 0.238372,0.0762 0.238372,0.23809 v 6.2169 c 0,0.15211 -0.104705,0.24722 -0.228741,0.24722" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path893"></path> <path d="m 75.054119,147.60001 h -3.10776 c -0.133668,0 -0.238372,-0.11437 -0.238372,-0.23837 v -6.11106 c 0,-0.12376 0.104704,-0.23841 0.238372,-0.23841 h 3.10776 c 0.162349,0 0.238125,0.11465 0.238125,0.23841 0,0.11437 -0.07578,0.22849 -0.238125,0.22849 h -2.831465 v 2.46945 h 1.992666 c 0.161925,0 0.238407,0.124 0.238407,0.24803 0,0.11437 -0.07648,0.22875 -0.238407,0.22875 h -2.040185 v 2.70756 h 2.878984 c 0.162349,0 0.238125,0.11438 0.238125,0.22878 0,0.124 -0.07578,0.23837 -0.238125,0.23837" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path895"></path> <path d="m 79.422496,142.75676 c 0,-0.70555 -0.572135,-1.27769 -1.27769,-1.27769 h -1.372941 v 5.65379 h 1.372941 c 0.705555,0 1.27769,-0.57188 1.27769,-1.27783 z m -1.27769,4.84325 h -1.601294 c -0.133668,0 -0.238407,-0.11437 -0.238407,-0.23837 v -6.11106 c 0,-0.12376 0.104739,-0.23841 0.238407,-0.23841 h 1.601294 c 0.962801,0 1.744592,0.77212 1.744592,1.74459 v 3.09827 c 0,0.96365 -0.781791,1.74498 -1.744592,1.74498" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path897"></path> <path d="m 82.78394,141.90833 -1.172704,3.58426 h 2.326146 z m 2.020922,5.7489 c -0.09511,0 -0.181221,-0.0474 -0.21911,-0.17159 l -0.505072,-1.5259 h -2.621703 l -0.476815,1.5259 c -0.03831,0.12418 -0.124001,0.17159 -0.21911,0.17159 -0.124001,0 -0.238654,-0.0854 -0.238654,-0.22877 0,-0.0185 0,-0.0475 0.0095,-0.0756 l 2.021311,-6.226 c 0.03789,-0.12382 0.133245,-0.1718 0.228742,-0.1718 0.09511,0 0.181222,0.0572 0.21911,0.1718 l 2.030554,6.226 c 0.0096,0.0281 0.0096,0.0474 0.0096,0.0756 0,0.14333 -0.11437,0.22877 -0.238372,0.22877" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path899"></path> <path d="m 61.142828,156.13092 c -0.190722,0 -0.371659,-0.0863 -0.486036,-0.31503 l -1.220664,-2.51615 -0.523932,0.7717 v 1.50604 c 0,0.37208 -0.276983,0.55344 -0.553282,0.55344 -0.276296,0 -0.552593,-0.18136 -0.552593,-0.55344 v -5.59622 c 0,-0.37137 0.276297,-0.55259 0.552593,-0.55259 0.276299,0 0.553282,0.18122 0.553282,0.55259 v 2.12648 c 0,0 1.086584,-1.62073 1.649236,-2.44066 0.114378,-0.17142 0.28622,-0.23841 0.448137,-0.23841 0.285945,0 0.571896,0.23841 0.571896,0.54367 0,0.1047 -0.03789,0.20944 -0.10474,0.31432 l -1.325259,1.95474 1.506199,3.09852 c 0.03817,0.0854 0.05704,0.17089 0.05704,0.25686 0,0.31503 -0.285785,0.53414 -0.571881,0.53414" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path901"></path> <path d="m 64.88918,151.2973 c 0,-0.44771 -0.352778,-0.77237 -0.801088,-0.77237 h -0.08569 c -0.448274,0 -0.801052,0.33415 -0.801052,0.77237 v 2.95522 c 0,0.44856 0.362408,0.78204 0.801052,0.78204 h 0.08569 c 0.44831,0 0.801088,-0.33348 0.801088,-0.77241 z m -0.801088,4.83362 h -0.08569 c -1.048843,0 -1.90694,-0.82007 -1.90694,-1.86877 v -2.96485 c 0,-1.05833 0.858097,-1.86863 1.90694,-1.86863 h 0.08569 c 1.058333,0 1.906517,0.8103 1.906517,1.86863 v 2.95522 c 0,1.05833 -0.848184,1.8784 -1.906517,1.8784" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path903"></path> <path d="m 69.645753,151.39237 c 0,-0.44785 -0.324273,-0.81011 -0.772407,-0.81011 h -0.97222 v 1.70656 h 1.000901 c 0.428837,0 0.743726,-0.37194 0.743726,-0.81016 z m -0.02854,1.84038 1.000725,2.10717 c 0.03817,0.0854 0.06685,0.17089 0.06685,0.24737 0,0.31475 -0.295593,0.54363 -0.581554,0.54363 -0.190853,0 -0.371793,-0.0952 -0.476533,-0.32399 l -1.153689,-2.42175 h -0.571888 v 2.1923 c 0,0.37208 -0.276295,0.55344 -0.553261,0.55344 -0.276296,0 -0.552591,-0.18136 -0.552591,-0.55344 v -5.53833 c 0,-0.29559 0.257422,-0.55326 0.552591,-0.55326 h 1.496836 c 1.058333,0 1.906905,0.84815 1.906905,1.90648 v 0.0863 c 0,0.791 -0.448275,1.4683 -1.134392,1.75409" style="fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.0352778" id="path905"></path> </g> </svg>', "", "", function(opts) {});

riot.tag2("kor-mass-action", '<h1>{tcap(\'nouns.action\')}</h1> <div class="amount"> {opts.ids.length} {t(\'activerecord.models.entity\', {count: \'other\'})} </div> <hr> <virtual if="{opts.ids.length}"> <a if="{allowedTo(\'create\') && allowedTo(\'delete\')}" class="action" href="#" onclick="{merge}">{tcap(\'clipboard_actions.merge\')}</a> <a if="{allowedTo(\'edit\')}" class="action" href="#" onclick="{massRelate}">{tcap(\'clipboard_actions.mass_relate\')}</a> <a if="{allowedTo(\'delete\')}" class="action" href="#" onclick="{massDelete}">{tcap(\'clipboard_actions.mass_delete\')}</a> <a if="{session().user.authority_group_admin}" class="action" href="#" onclick="{addToAuthorityGroup}">{tcap(\'clipboard_actions.add_to_authority_group\')}</a> <a class="action" href="#" onclick="{addToUserGroup}">{tcap(\'clipboard_actions.add_to_user_group\')}</a> </virtual>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.i18n);
    tag.merge = function(event) {
        event.preventDefault();
        wApp.bus.trigger("modal", "kor-entity-merger", {
            ids: tag.opts.ids
        });
    };
    tag.massRelate = function(event) {
        event.preventDefault();
        wApp.bus.trigger("modal", "kor-mass-relate", {
            ids: wApp.clipboard.subSelection()
        });
    };
    tag.massDelete = function(event) {
        event.preventDefault();
        if (wApp.utils.confirm()) {
            var data = {
                ids: wApp.clipboard.subSelection()
            };
            Zepto.ajax({
                type: "DELETE",
                url: "/tools/mass_delete",
                data: JSON.stringify(data),
                success: function(data) {
                    var ids = wApp.clipboard.subSelection();
                    for (var i = 0; i < ids.length; i++) {
                        wApp.clipboard.remove(ids[i]);
                    }
                    notify();
                }
            });
        }
    };
    var addToEntityGroup = function(type) {
        wApp.bus.trigger("modal", "kor-to-entity-group", {
            type: type,
            entityIds: wApp.clipboard.subSelection()
        });
    };
    tag.addToAuthorityGroup = function(event) {
        event.preventDefault();
        addToEntityGroup("authority");
    };
    tag.addToUserGroup = function(event) {
        event.preventDefault();
        addToEntityGroup("user");
    };
    tag.moveToCollection = function(event) {
        event.preventDefault();
    };
    var notify = function() {
        var h = tag.opts.onActionSuccess;
        if (h) {
            h();
        }
    };
});

riot.tag2("kor-media-relation", '<div class="name"> {opts.name} <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" on-paginate="{pageUpdate}"></kor-pagination> <div class="clearfix"></div> </div> <virtual if="{data}"> <kor-relationship each="{relationship in data.records}" entity="{parent.opts.entity}" relationship="{relationship}"></kor-relationship> </virtual>', "", "", function(opts) {
    var fetch, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.info);
    tag.on("mount", function() {
        var base;
        wApp.bus.on("relationship-created", fetch);
        wApp.bus.on("relationship-updated", fetch);
        wApp.bus.on("relationship-deleted", fetch);
        (base = tag.opts).query || (base.query = {});
        return fetch();
    });
    tag.on("unmount", function() {
        wApp.bus.off("relationship-deleted", fetch);
        wApp.bus.off("relationship-updated", fetch);
        return wApp.bus.off("relationship-created", fetch);
    });
    tag.pageUpdate = function(newPage) {
        opts.query.page = newPage;
        return fetch();
    };
    tag.refresh = function() {
        return fetch();
    };
    fetch = function() {
        return Zepto.ajax({
            url: "relationships",
            data: {
                from_entity_id: tag.opts.entity.id,
                page: tag.opts.query.page,
                relation_name: tag.opts.name,
                to_kind_id: tag.info().medium_kind_id,
                include: "all"
            },
            success: function(data) {
                tag.data = data;
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

riot.tag2("kor-nothing-found", "<span>{t('no_results')}</span>", "", 'show="{!opts.data || opts.data.total == 0}"', function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
});

riot.tag2("kor-about", '<div class="kor-layout-left kor-layout-large"> <div class="kor-content-box"> <div class="target"></div> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.config);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        tag.title(tag.t("about"));
        return Zepto(tag.root).find(".target").html(tag.config().legal_html);
    });
});

riot.tag2("kor-access-denied", '<div class="kor-layout-left kor-layout-large kor-clear-after"> <div class="kor-content-box"> <h1>{tcap(\'access_denied\')}</h1> {t(\'messages.access_denied\')} <div class="hr"></div> <a href="#/login?return_to={returnTo()}">{t(\'verbs.login\')}</a> | <a href="#" onclick="{back}">{t(\'back\')}</a> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.returnTo = function() {
        return encodeURIComponent(wApp.routing.fragment());
    };
    tag.back = function(event) {
        event.preventDefault();
        return wApp.bus.trigger("go-back");
    };
});

riot.tag2("kor-admin-group-categories", '<kor-help-button key="authority_groups"></kor-help-button> <div class="kor-layout-left kor-layout-small"> <div class="kor-content-box"> <a if="{!opts.type && isAuthorityGroupAdmin()}" href="{newCategoryUrl()}" class="pull-right" title="{t(\'objects.new\', {interpolations: {o: t(\'activerecord.models.authority_group_category\')}})}"><i class="fa fa-plus-square"></i></a> <h1> {tcap(\'activerecord.models.authority_group_category\', {count: \'other\'})} </h1> <p class="ancestry" if="{parentCategory}"> <a href="#/groups/categories">{t(\'nouns.top_level\')}</a> <virtual each="{a in parentCategory.ancestors}"> <span class="separator">»</span> <a href="#/groups/categories/{a.id}">{a.name}</a> </virtual> <span class="separator">»</span> <span>{parentCategory.name}</span> </p> <table if="{data && data.total > 0}"> <thead> <tr> <th>{tcap(\'activerecord.attributes.authority_group_category.name\')}</th> <th if="{isAuthorityGroupAdmin()}"></th> </tr> </thead> <tbody> <tr each="{category in data.records}"> <td> <a href="#/groups/categories/{category.id}">{category.name}</td> <td class="right nowrap" if="{isAuthorityGroupAdmin()}"> <a href="#/groups/categories/{category.id}/edit" title="{t(\'verbs.edit\')}"><i class="fa fa-pencil"></i></a> <a href="#/groups/categories/{category.id}" title="{t(\'verbs.delete\')}" onclick="{onDeleteClicked}"><i class="fa fa-trash"></i></a> </td> </tr> </tbody> </table> </div> </div> <div class="kor-layout-right kor-layout-large"> <kor-admin-groups category-id="{opts.parentId}"></kor-admin-groups> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        if (tag.opts.parentId) {
            fetchParent();
        }
        fetch();
    });
    tag.newCategoryUrl = function() {
        if (tag.opts.parentId) {
            return "#/groups/categories/" + tag.opts.parentId + "/new";
        }
        return "#/groups/categories/new";
    };
    tag.onDeleteClicked = function(event) {
        event.preventDefault();
        if (wApp.utils.confirm()) destroy(event.item.category.id);
    };
    var destroy = function(id) {
        Zepto.ajax({
            type: "DELETE",
            url: "/authority_group_categories/" + id,
            success: fetch
        });
    };
    var fetchParent = function() {
        Zepto.ajax({
            url: "/authority_group_categories/" + tag.opts.parentId,
            data: {
                include: "ancestors"
            },
            success: function(data) {
                tag.parentCategory = data;
                tag.update();
            }
        });
    };
    var fetch = function() {
        Zepto.ajax({
            url: "/authority_group_categories",
            data: {
                parent_id: tag.opts.parentId
            },
            success: function(data) {
                tag.data = data;
                tag.update();
            }
        });
    };
});

riot.tag2("kor-admin-group-category-editor", '<div class="kor-layout-left kor-layout-large"> <div class="kor-content-box"> <h1 if="{opts.id}"> {tcap(\'objects.edit\', {interpolations: {o: \'activerecord.models.authority_group_category\'}})} </h1> <h1 if="{!opts.id}"> {tcap(\'objects.create\', {interpolations: {o: \'activerecord.models.authority_group_category\'}})} </h1> <form onsubmit="{submit}" if="{data}"> <kor-input label="{tcap(\'activerecord.attributes.authority_group.name\')}" name="name" ref="fields" riot-value="{data.name}" errors="{errors.name}"></kor-input> <kor-input if="{categories}" label="{tcap(\'activerecord.models.authority_group_category\')}" name="parent_id" type="select" options="{categories}" placeholder="" ref="fields" riot-value="{data.parent_id || opts.parentId}" errors="{errors.parent_id}"></kor-input> <hr> <kor-input type="submit"></kor-input> </form> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var create, fetch, fetchCategories, tag, update, values;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    tag.on("before-mount", function() {
        fetchCategories();
        tag.errors = {};
        tag.data = {};
        if (!tag.isAuthorityGroupAdmin()) {
            return wApp.bus.trigger("access-denied");
        }
    });
    tag.on("mount", function() {
        if (tag.opts.id) {
            return fetch();
        }
    });
    tag.submit = function(event) {
        var p;
        event.preventDefault();
        p = tag.opts.id ? update() : create();
        p.done(function(data) {
            var id;
            tag.errors = {};
            if (id = values()["parent_id"]) {
                return wApp.routing.path("/groups/categories/" + id);
            } else {
                return wApp.routing.path("/groups/categories");
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
    fetch = function() {
        return Zepto.ajax({
            url: "/authority_group_categories/" + tag.opts.id,
            success: function(data) {
                tag.data = data;
                return tag.update();
            }
        });
    };
    fetchCategories = function() {
        return Zepto.ajax({
            url: "/authority_group_categories/flat",
            data: {
                include: "ancestors"
            },
            success: function(data) {
                var a, i, len, names, r, ref, results;
                results = [ {
                    value: "0",
                    label: tag.t("none")
                } ];
                ref = data.records;
                for (i = 0, len = ref.length; i < len; i++) {
                    r = ref[i];
                    if (r.id !== tag.opts.id) {
                        names = function() {
                            var j, len1, ref1, results1;
                            ref1 = r.ancestors;
                            results1 = [];
                            for (j = 0, len1 = ref1.length; j < len1; j++) {
                                a = ref1[j];
                                results1.push(a.name);
                            }
                            return results1;
                        }();
                        names.push(r.name);
                        results.push({
                            value: r.id,
                            label: names.join(" » ")
                        });
                    }
                }
                tag.categories = results;
                return tag.update();
            }
        });
    };
    create = function() {
        return Zepto.ajax({
            type: "POST",
            url: "/authority_group_categories",
            data: JSON.stringify({
                authority_group_category: values()
            })
        });
    };
    update = function() {
        return Zepto.ajax({
            type: "PATCH",
            url: "/authority_group_categories/" + tag.opts.id,
            data: JSON.stringify({
                authority_group_category: values()
            })
        });
    };
    values = function() {
        var f, i, len, ref, results;
        results = {};
        ref = wApp.utils.toArray(tag.refs.fields);
        for (i = 0, len = ref.length; i < len; i++) {
            f = ref[i];
            results[f.name()] = f.value();
        }
        return results;
    };
});

riot.tag2("kor-admin-group-editor", '<div class="kor-layout-left kor-layout-large"> <div class="kor-content-box"> <h1 if="{opts.id}"> {tcap(\'objects.edit\', {interpolations: {o: \'activerecord.models.authority_group\'}})} </h1> <h1 if="{!opts.id}"> {tcap(\'objects.create\', {interpolations: {o: \'activerecord.models.authority_group\'}})} </h1> <form onsubmit="{submit}" if="{data}"> <kor-input label="{tcap(\'activerecord.attributes.authority_group.name\')}" name="name" ref="fields" riot-value="{data.name}" errors="{errors.name}"></kor-input> <kor-input if="{categories}" label="{tcap(\'activerecord.models.authority_group_category\')}" name="authority_group_category_id" type="select" options="{categories}" placeholder="" ref="fields" riot-value="{data.authority_group_category_id}" errors="{errors.authority_group_category_id}"></kor-input> <hr> <kor-input type="submit"></kor-input> </form> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var create, fetch, fetchCategories, tag, update, values;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    tag.on("before-mount", function(e) {
        tag.errors = {};
        fetchCategories();
        if (!tag.isAuthorityGroupAdmin()) {
            wApp.bus.trigger("access-denied");
            throw "access denied";
        }
    });
    tag.on("mount", function() {
        if (tag.opts.id) {
            return fetch();
        } else {
            tag.data = {};
            return tag.data.authority_group_category_id = tag.opts.categoryId;
        }
    });
    tag.submit = function(event) {
        var p;
        event.preventDefault();
        p = tag.opts.id ? update() : create();
        p.done(function(data) {
            var id;
            tag.errors = {};
            if (id = values()["authority_group_category_id"]) {
                return wApp.routing.path("/groups/categories/" + id);
            } else {
                return wApp.routing.path("/groups/categories");
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
    fetch = function() {
        return Zepto.ajax({
            url: "/authority_groups/" + tag.opts.id,
            success: function(data) {
                tag.data = data;
                return tag.update();
            }
        });
    };
    fetchCategories = function() {
        return Zepto.ajax({
            url: "/authority_group_categories/flat",
            data: {
                include: "ancestors"
            },
            success: function(data) {
                var a, i, len, names, r, ref, results;
                results = [ {
                    value: "0",
                    label: tag.t("none")
                } ];
                ref = data.records;
                for (i = 0, len = ref.length; i < len; i++) {
                    r = ref[i];
                    names = function() {
                        var j, len1, ref1, results1;
                        ref1 = r.ancestors;
                        results1 = [];
                        for (j = 0, len1 = ref1.length; j < len1; j++) {
                            a = ref1[j];
                            results1.push(a.name);
                        }
                        return results1;
                    }();
                    names.push(r.name);
                    results.push({
                        value: r.id,
                        label: names.join(" » ")
                    });
                }
                tag.categories = results;
                return tag.update();
            }
        });
    };
    create = function() {
        return Zepto.ajax({
            type: "POST",
            url: "/authority_groups",
            data: JSON.stringify({
                authority_group: values()
            })
        });
    };
    update = function() {
        return Zepto.ajax({
            type: "PATCH",
            url: "/authority_groups/" + tag.opts.id,
            data: JSON.stringify({
                authority_group: values()
            })
        });
    };
    values = function() {
        var f, i, len, ref, results;
        results = {};
        ref = wApp.utils.toArray(tag.refs.fields);
        for (i = 0, len = ref.length; i < len; i++) {
            f = ref[i];
            results[f.name()] = f.value();
        }
        return results;
    };
});

riot.tag2("kor-admin-groups", '<div class="kor-content-box"> <a if="{!opts.type && isAuthorityGroupAdmin()}" href="{baseUrl()}/new" class="pull-right" title="{t(\'objects.new\', {interpolations: {o: t(\'activerecord.models.authority_group\')}})}"><i class="fa fa-plus-square"></i></a> <h1> {tcap(\'activerecord.models.authority_group\', {count: \'other\'})} </h1> <table if="{data && data.total > 0}"> <thead> <tr> <th>{tcap(\'activerecord.attributes.authority_group.name\')}</th> <th if="{isAuthorityGroupAdmin()}"></th> </tr> </thead> <tbody> <tr each="{group in data.records}"> <td> <a href="#/groups/admin/{group.id}">{group.name}</td> <td class="right nowrap" if="{isAuthorityGroupAdmin()}"> <a href="{baseUrl()}/{group.id}/edit" title="{t(\'verbs.edit\')}"><i class="fa fa-pencil"></i></a> <a href="{baseUrl()}/{group.id}" title="{t(\'verbs.delete\')}" onclick="{onDeleteClicked}"><i class="fa fa-trash"></i></a> </td> </tr> </tbody> </table> </div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        tag.title(tag.tcap("activerecord.models.authority_group", {
            count: "other"
        }));
        fetch();
    });
    tag.baseUrl = function() {
        if (tag.opts.categoryId) {
            return "#/groups/categories/" + tag.opts.categoryId + "/admin";
        }
        return "#/groups/categories/admin";
    };
    tag.onDeleteClicked = function(event) {
        event.preventDefault();
        if (wApp.utils.confirm()) destroy(event.item.group.id);
    };
    var destroy = function(id) {
        Zepto.ajax({
            type: "DELETE",
            url: "/authority_groups/" + id,
            success: fetch
        });
    };
    var fetch = function() {
        Zepto.ajax({
            url: "/authority_groups",
            data: {
                authority_group_category_id: tag.opts.categoryId
            },
            success: function(data) {
                tag.data = data;
                tag.update();
            }
        });
    };
});

riot.tag2("kor-clipboard", '<kor-help-button key="clipboard"></kor-help-button> <div class="kor-layout-left kor-layout-large"> <div class="kor-content-box"> <div class="kor-layout-commands"> <a onclick="{reset}"><i class="fa fa-minus-square"></i></a> </div> <h1>{tcap(\'nouns.clipboard\')}</h1> <div class="mass-subselect"> <a href="#" onclick="{selectAll}">{t(\'all\')}</a> | <a href="#" onclick="{selectNone}">{t(\'none\')}</a> </div> <kor-pagination if="{data}" page="{data.page}" per-page="{data.per_page}" total="{data.total}" on-paginate="{page}" per-page-control="{true}"></kor-pagination> <div class="clearfix"></div> <hr> <span show="{data && data.total == 0}"> {tcap(\'objects.none_found\', {interpolations: {o: \'nouns.entity.one\'}})} </span> <kor-nothing-found data="{data}"></kor-nothing-found> <table if="{data}"> <tbody> <tr each="{entity in data.records}"> <td> <kor-clipboard-subselect-control entity="{entity}"></kor-clipboard-subselect-control> </td> <td> <a href="#/entities/{entity.id}"> <span show="{!entity.medium}">{entity.display_name}</span> <img if="{entity.medium}" riot-src="{entity.medium.url.icon}" class="image"> </a> </td> <td class="right nobreak"> <a onclick="{remove(entity.id)}"><i class="minus"></i></a> </td> </tr> </tbody> </table> </div> </div> <div class="kor-layout-right kor-layout-small"> <div class="kor-content-box"> <kor-mass-action if="{data}" ids="{selectedIds()}" on-action-success="{reload}"></kor-mass-action> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        tag.title(tag.t("nouns.clipboard"));
        wApp.bus.trigger("page-title", tag.tcap("nouns.clipboard"));
        wApp.bus.on("routing:query", fetch);
        wApp.bus.on("clipboard-subselection-changed", tag.update);
        if (tag.currentUser() && !tag.isGuest()) {
            fetch();
        } else {
            wApp.bus.trigger("access-denied");
        }
    });
    tag.on("umount", function() {
        wApp.bus.off("routing:query", fetch);
        wApp.bus.off("clipboard-subselection-changed", tag.update);
    });
    tag.reload = function() {
        fetch();
    };
    tag.selectAll = function(event) {
        event.preventDefault();
        wApp.clipboard.subSelectAll();
    };
    tag.selectNone = function(event) {
        event.preventDefault();
        wApp.clipboard.resetSubSelection();
    };
    tag.selectedIds = function() {
        return wApp.clipboard.subSelection();
    };
    tag.reset = function(event) {
        event.preventDefault();
        wApp.clipboard.reset();
        fetch();
    };
    tag.remove = function(id) {
        return function(event) {
            event.preventDefault();
            wApp.clipboard.remove(id);
            fetch();
        };
    };
    tag.page = function(newPage, newPerPage) {
        wApp.routing.query({
            page: newPage,
            per_page: newPerPage
        });
    };
    var urlParams = function() {
        var results = wApp.routing.query();
        results["id"] = wApp.clipboard.ids().join(",");
        return results;
    };
    var fetch = function() {
        wApp.clipboard.checkEntityExistence().then(function() {
            var params = urlParams();
            if (params["id"].length) {
                Zepto.ajax({
                    url: "/entities",
                    data: urlParams(),
                    success: function(data) {
                        tag.data = data;
                        tag.update();
                    }
                });
            } else {
                tag.data = null;
                tag.update();
            }
        });
    };
});

riot.tag2("kor-collection-editor", '<div class="kor-layout-left kor-layout-large"> <div class="kor-content-box"> <h1 if="{opts.id}"> {tcap(\'objects.edit\', {interpolations: {o: \'activerecord.models.collection\'}})} </h1> <h1 if="{!opts.id}"> {tcap(\'objects.create\', {interpolations: {o: \'activerecord.models.collection\'}})} </h1> <form onsubmit="{submit}" if="{data}"> <kor-input label="{tcap(\'activerecord.attributes.collection.name\')}" name="name" ref="fields" riot-value="{data.name}" errors="{errors.name}"></kor-input> <virtual if="{credentials}"> <hr> <kor-input each="{policy in policies}" label="{tcap(\'activerecord.attributes.collection.\' + policy)}" name="{policy}" type="select" multiple="{true}" options="{credentials.records}" riot-value="{data.permissions[policy]}" ref="permissions"></kor-input> </virtual> <hr> <kor-input type="submit"></kor-input> </form> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var create, fetch, fetchCredentials, tag, update, values;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.policies = [ "view", "edit", "create", "delete", "download_originals", "tagging", "view_meta" ];
    tag.on("before-mount", function() {
        return tag.errors = {};
    });
    tag.on("mount", function() {
        if (tag.opts.id) {
            fetch();
        } else {
            tag.data = {};
        }
        return fetchCredentials();
    });
    tag.submit = function(event) {
        var p;
        event.preventDefault();
        p = tag.opts.id ? update() : create();
        p.done(function(data) {
            tag.errors = {};
            return window.history.back();
        });
        p.fail(function(xhr) {
            tag.errors = JSON.parse(xhr.responseText).errors;
            return wApp.utils.scrollToTop();
        });
        return p.always(function() {
            return tag.update();
        });
    };
    fetch = function() {
        return Zepto.ajax({
            url: "/collections/" + tag.opts.id,
            data: {
                include: "permissions"
            },
            success: function(data) {
                tag.data = data;
                return tag.update();
            }
        });
    };
    create = function() {
        return Zepto.ajax({
            type: "POST",
            url: "/collections",
            data: JSON.stringify({
                collection: values()
            })
        });
    };
    update = function() {
        return Zepto.ajax({
            type: "PATCH",
            url: "/collections/" + tag.opts.id,
            data: JSON.stringify({
                collection: values()
            })
        });
    };
    values = function() {
        var base, f, i, len, name, ref, results;
        results = {
            name: tag.refs.fields.value(),
            permissions: {}
        };
        ref = tag.refs.permissions;
        for (i = 0, len = ref.length; i < len; i++) {
            f = ref[i];
            (base = results.permissions)[name = f.name()] || (base[name] = f.value());
        }
        return results;
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
});

riot.tag2("kor-collections", '<div class="kor-content-box"> <a href="#/collections/new" class="pull-right" title="{t(\'objects.new\', {interpolations: {o: t(\'activerecord.models.collection\')}})}"><i class="fa fa-plus-square"></i></a> <h1>{tcap(\'activerecord.models.collection\', {count: \'other\'})}</h1> <table> <thead> <th>{tcap(\'activerecord.attributes.collection.name\')}</th> <th class="right"># {tcap(\'activerecord.models.entity.other\')}</th> <th class="right"></th> </thead> <tbody if="{data}"> <tr each="{collection in data.records}"> <td> {collection.name} <span if="{collection.owner}"> ({t(\'activerecord.models.user\')}: <a href="#/users/{collection.owner.id}/edit">{collection.owner.full_name}</a>) </span> </td> <td class="right">{collection.entity_count}</td> <td class="right"> <a href="#/collections/{collection.id}/edit" title="{t(\'verbs.edit\')}"><i class="fa fa-pencil"></i></a> <a href="#/collections/{collection.id}/destroy" onclick="{onDeleteClicked}" title="{t(\'verbs.delete\')}"><i class="fa fa-trash"></i></a> </td> </tr> </tbody> </table> </div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        tag.title(tag.t("activerecord.models.collection", {
            count: "other"
        }));
        fetch();
    });
    tag.onDeleteClicked = function(event) {
        event.preventDefault();
        if (wApp.utils.confirm()) destroy(event.item.collection.id);
    };
    var destroy = function(id) {
        Zepto.ajax({
            type: "DELETE",
            url: "/collections/" + id,
            success: fetch,
            error: function(xhr) {
                tag.errors = JSON.parse(xhr.responseText).errors;
                wApp.utils.scrollToTop();
            }
        });
    };
    fetch = function() {
        Zepto.ajax({
            url: "/collections",
            data: {
                include: "counts,owner"
            },
            success: function(data) {
                tag.data = data;
                tag.update();
            }
        });
    };
    tag.fetch = fetch;
});

riot.tag2("kor-credential-editor", '<div class="kor-layout-left kor-layout-large"> <div class="kor-content-box"> <h1 if="{opts.id}"> {tcap(\'objects.edit\', {interpolations: {o: \'activerecord.models.credential\'}})} </h1> <h1 if="{!opts.id}"> {tcap(\'objects.create\', {interpolations: {o: \'activerecord.models.credential\'}})} </h1> <form onsubmit="{submit}" if="{data}"> <kor-input label="{tcap(\'activerecord.attributes.credential.name\')}" name="name" ref="fields" riot-value="{data.name}" errors="{errors.name}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.credential.description\')}" name="description" type="textarea" ref="fields" riot-value="{data.description}" errors="{errors.description}"></kor-input> <hr> <kor-input type="submit"></kor-input> </form> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var create, fetch, tag, update, values;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.on("before-mount", function() {
        tag.errors = {};
        return tag.data = {};
    });
    tag.on("mount", function() {
        if (tag.opts.id) {
            return fetch();
        }
    });
    tag.submit = function(event) {
        var p;
        event.preventDefault();
        p = tag.opts.id ? update() : create();
        p.done(function(data) {
            tag.errors = {};
            return window.history.back();
        });
        p.fail(function(xhr) {
            tag.errors = JSON.parse(xhr.responseText).errors;
            return wApp.utils.scrollToTop();
        });
        return p.always(function() {
            return tag.update();
        });
    };
    fetch = function() {
        return Zepto.ajax({
            url: "/credentials/" + tag.opts.id,
            success: function(data) {
                tag.data = data;
                return tag.update();
            }
        });
    };
    create = function() {
        return Zepto.ajax({
            type: "POST",
            url: "/credentials",
            data: JSON.stringify({
                credential: values()
            })
        });
    };
    update = function() {
        return Zepto.ajax({
            type: "PATCH",
            url: "/credentials/" + tag.opts.id,
            data: JSON.stringify({
                credential: values()
            })
        });
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

riot.tag2("kor-credentials", '<div class="kor-content-box"> <a href="#/credentials/new" class="pull-right" title="{t(\'objects.new\', {interpolations: {o: t(\'activerecord.models.credential\')}})}"><i class="fa fa-plus-square"></i></a> <h1>{tcap(\'activerecord.models.credential\', {count: \'other\'})}</h1> <table> <thead> <th>{tcap(\'activerecord.attributes.credential.name\')}</th> <th class="right"># {tcap(\'activerecord.attributes.credential.user_count\')}</th> <th class="right"></th> </thead> <tbody if="{data}"> <tr each="{credential in data.records}"> <td> <strong>{credential.name}</strong> <div if="{credential.description}">{credential.description}</div> </td> <td class="right">{credential.user_count}</td> <td class="right"> <a href="#/credentials/{credential.id}/edit" title="{t(\'verbs.edit\')}"><i class="fa fa-pencil"></i></a> <a href="#/credentials/{credential.id}/destroy" onclick="{onDeleteClicked}" title="{t(\'verbs.delete\')}"><i class="fa fa-trash"></i></a> </td> </tr> </tbody> </table> </div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        tag.title(tag.t("activerecord.models.credential", {
            count: "other"
        }));
        if (!tag.isAdmin()) {
            wApp.bus.trigger("access-denied");
            return;
        }
        fetch();
    });
    tag.onDeleteClicked = function(event) {
        event.preventDefault();
        if (wApp.utils.confirm()) destroy(event.item.credential.id);
    };
    var destroy = function(id) {
        Zepto.ajax({
            type: "DELETE",
            url: "/credentials/" + id,
            success: fetch,
            error: function(xhr) {
                tag.errors = JSON.parse(xhr.responseText).errors;
                wApp.utils.scrollToTop();
            }
        });
    };
    fetch = function() {
        Zepto.ajax({
            url: "/credentials",
            data: {
                include: "counts"
            },
            success: function(data) {
                tag.data = data;
                tag.update();
            }
        });
    };
});

riot.tag2("kor-entity-editor", '<div class="kor-layout-left kor-layout-large"> <div class="kor-content-box"> <h1 if="{opts.id}"> {tcap(\'objects.edit\', {interpolations: {o: \'activerecord.models.entity\'}})} </h1> <h1 if="{!opts.id && kind}"> {tcap(\'objects.create\', {interpolations: {o: kind.name}})} </h1> <form onsubmit="{submit}" if="{data}"> <kor-input name="lock_version" riot-value="{data.lock_version || 0}" ref="fields" type="hidden"></kor-input> <kor-input if="{collections}" label="{tcap(\'activerecord.attributes.entity.collection_id\')}" name="collection_id" type="select" options="{collections}" ref="fields" riot-value="{data.collection_id}" errors="{errors.collection_id}"></kor-input> <hr> <virtual if="{!isMedium()}"> <kor-input label="{tcap(\'activerecord.attributes.entity.naming_options\')}" name="no_name_statement" type="radio" ref="fields.no_name_statement" riot-value="{data.no_name_statement}" options="{noNameStatements}" onchange="{update}" errors="{errors.no_name_statement}"></kor-input> <kor-input label="{nameLabel()}" if="{hasName()}" name="name" ref="fields" riot-value="{data.name}" errors="{errors.name}"></kor-input> <kor-input if="{hasName()}" label="{distinctNameLabel()}" name="distinct_name" ref="fields" riot-value="{data.distinct_name}" errors="{errors.distinct_name}"></kor-input> <hr> </virtual> <kor-input label="{tcap(\'activerecord.attributes.entity.subtype\')}" name="subtype" ref="fields" riot-value="{data.subtype}" errors="{errors.subtype}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.entity.tag_list\')}" name="tag_list" ref="fields" riot-value="{data.tags.join(\', \')}" errors="{errors.tag_list}"></kor-input> <kor-dataset-fields if="{kind}" name="dataset" fields="{kind.fields}" values="{data.dataset}" ref="fields" errors="{errors.dataset}"></kor-dataset-fields> <kor-input label="{tcap(\'activerecord.attributes.entity.comment\')}" name="comment" ref="fields" type="textarea" riot-value="{data.comment}" errors="{errors.comment}"></kor-input> <hr> <kor-synonyms-editor label="{tcap(\'activerecord.attributes.entity.synonyms\')}" name="synonyms" ref="fields" riot-value="{data.synonyms}"></kor-synonyms-editor> <hr> <kor-datings-editor if="{kind}" label="{tcap(\'activerecord.models.entity_dating\', {count: \'other\'})}" name="datings_attributes" ref="fields" riot-value="{data.datings}" errors="{errors.datings}" for="entity" kind="{kind}" default-dating-label="{kind.dating_label}"></kor-datings-editor> <hr> <kor-entity-properties-editor label="{tcap(\'activerecord.attributes.entity.properties\')}" name="properties" ref="fields" riot-value="{data.properties}"></kor-entity-properties-editor> <hr> <kor-input type="submit"></kor-input> </form> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var checkPermissions, create, defaults, fetch, fetchCollections, fetchKind, queryHandler, tag, update, values;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.on("before-mount", function() {
        tag.errors = {};
        tag.dating_errors = [];
        return tag.noNameStatements = [ {
            label: tag.t("values.no_name_statements.unknown"),
            value: "unknown"
        }, {
            label: tag.t("values.no_name_statements.not_available"),
            value: "not_available"
        }, {
            label: tag.t("values.no_name_statements.empty_name"),
            value: "empty_name"
        }, {
            label: tag.t("values.no_name_statements.enter_name"),
            value: "enter_name"
        } ];
    });
    tag.on("mount", function() {
        checkPermissions();
        fetchCollections();
        wApp.bus.on("routing:query", queryHandler);
        return fetch(tag.opts.kindId);
    });
    tag.on("unmount", function() {
        return wApp.bus.off("routing:query", queryHandler);
    });
    tag.submit = function(event) {
        var p;
        event.preventDefault();
        p = tag.opts.id ? update() : create();
        p.done(function(data) {
            var id;
            tag.errors = {};
            id = tag.opts.id || data.id;
            return wApp.routing.path("/entities/" + id);
        });
        p.fail(function(xhr) {
            tag.errors = JSON.parse(xhr.responseText).errors;
            return wApp.utils.scrollToTop();
        });
        return p.always(function() {
            return tag.update();
        });
    };
    tag.isMedium = function() {
        var kindId;
        kindId = parseInt(tag.data["kind_id"]) || tag.opts.kindId;
        return kindId === wApp.info.data.medium_kind_id;
    };
    tag.hasName = function() {
        var field;
        field = tag.refs["fields.no_name_statement"];
        return !!field && field.value() === "enter_name";
    };
    tag.nameLabel = function() {
        if (!tag.kind) {
            return "";
        }
        return wApp.utils.capitalize(tag.kind.name_label);
    };
    tag.distinctNameLabel = function() {
        if (!tag.kind) {
            return "";
        }
        return wApp.utils.capitalize(tag.kind.distinct_name_label);
    };
    checkPermissions = function() {
        var policy;
        policy = tag.opts.id ? "edit" : "create";
        if (tag.currentUser().permissions.collections[policy].length === 0) {
            return wApp.bus.trigger("access-denied");
        }
    };
    queryHandler = function(parts) {
        if (parts == null) {
            parts = {};
        }
        return fetch(parts["hash_query"]["kind_id"]);
    };
    defaults = function(kind_id) {
        return {
            kind_id: kind_id,
            no_name_statement: "enter_name",
            lock_version: 0,
            tags: [],
            datings: []
        };
    };
    fetch = function(kind_id) {
        if (tag.opts.id) {
            return Zepto.ajax({
                url: "/entities/" + tag.opts.id,
                data: {
                    include: "dataset,synonyms,properties,datings"
                },
                success: function(data) {
                    tag.data = data;
                    return fetchKind();
                }
            });
        } else {
            tag.data = {
                kind_id: kind_id,
                no_name_statement: "enter_name",
                tags: []
            };
            return fetchKind();
        }
    };
    fetchKind = function() {
        return Zepto.ajax({
            url: "/kinds/" + (tag.data["kind_id"] || tag.opts.kindId),
            data: {
                include: "fields,settings"
            },
            success: function(data) {
                tag.kind = data;
                return tag.update();
            }
        });
    };
    fetchCollections = function() {
        return Zepto.ajax({
            url: "/collections",
            success: function(data) {
                tag.collections = data.records;
                return tag.update();
            }
        });
    };
    create = function() {
        return Zepto.ajax({
            type: "POST",
            url: "/entities",
            data: JSON.stringify({
                entity: values()
            })
        });
    };
    update = function() {
        return Zepto.ajax({
            type: "PATCH",
            url: "/entities/" + tag.opts.id,
            data: JSON.stringify({
                entity: values()
            })
        });
    };
    values = function() {
        var f, i, len, ref, results;
        results = {};
        if (!tag.isMedium()) {
            results.no_name_statement = tag.refs["fields.no_name_statement"].value();
        }
        results.kind_id = tag.data.kind_id || tag.opts.kindId;
        ref = tag.refs.fields;
        for (i = 0, len = ref.length; i < len; i++) {
            f = ref[i];
            results[f.name()] = f.value();
        }
        return results;
    };
});

riot.tag2("kor-entity-group", '<div class="kor-content-box"> <div class="kor-text-right pull-right group-commands"> <a if="{opts.type == \'user\' || opts.type == \'authority\'}" href="#" title="{t(\'add_to_clipboard\')}" onclick="{onMarkClicked}"><i class="fa fa-clipboard"></i></a> <a if="{opts.type == \'user\'}" href="/user_groups/{opts.id}/download_images" title="{t(\'title_verbs.zip\')}"><i class="fa fa-download"></i></a> <a if="{opts.type == \'authority\'}" href="/authority_groups/{opts.id}/download_images" title="{t(\'title_verbs.zip\')}"><i class="fa fa-download"></i></a> </div> <h1> {tcap(\'activerecord.models.\' + opts.type + \'_group\')} <span if="{group}">"{group.name}"</span> </h1> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> <div class="hr"></div> <span show="{data && data.total == 0}"> {tcap(\'objects.none_found\', {interpolations: {o: \'activerecord.models.entity.other\'}})} </span> <kor-gallery-grid if="{data}" entities="{data.records}"></kor-gallery-grid> <div class="hr"></div> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> </div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        fetchGroup();
        tag.on("routing:query", fetch);
    });
    tag.on("unmount", function() {
        tag.off("routing:query", fetch);
    });
    tag.onMarkClicked = function(event, page) {
        event.preventDefault();
        var params = {
            page: page || 1
        };
        params[tag.opts.type + "_group_id"] = tag.opts.id;
        Zepto.ajax({
            url: "/entities",
            data: params,
            success: function(data) {
                if (data.total > data.page * data.per_page) {
                    tag.onMarkClicked(event, page + 1);
                } else {
                    wApp.bus.trigger("message", "notice", tag.t("objects.marked_entities_success"));
                }
                for (var i = 0; i < data.records.length; i++) {
                    wApp.clipboard.add(data.records[i].id);
                }
            }
        });
    };
    var fetchGroup = function() {
        return Zepto.ajax({
            url: "/" + tag.opts.type + "_groups/" + tag.opts.id,
            success: function(data) {
                tag.group = data;
                wApp.bus.trigger("page-title", data.name);
                fetch();
            },
            error: function() {
                wApp.bus.trigger("access-denied");
            }
        });
    };
    var fetch = function() {
        var params = {
            include: "gallery_data,kind",
            page: tag.opts.query.page
        };
        if (tag.opts.type == "user") {
            params["user_group_id"] = tag.opts.id;
        }
        if (tag.opts.type == "authority") {
            params["authority_group_id"] = tag.opts.id;
        }
        return Zepto.ajax({
            url: "/entities",
            data: params,
            success: function(data) {
                tag.data = data;
                tag.update();
            }
        });
    };
});

riot.tag2("kor-entity-page", '<div class="kor-layout-left kor-layout-large" if="{data}"> <div class="kor-content-box"> <div class="kor-layout-commands page-commands"> <kor-clipboard-control entity="{data}"></kor-clipboard-control> <virtual if="{allowedTo(\'edit\', data.collection_id)}"> <a href="#/entities/{data.id}/edit" title="{t(\'verbs.edit\')}"><i class="fa fa-pencil"></i></a> </virtual> <a href="{reportUrl()}" title="{tcap(\'objects.report\', {interpolations: {o: \'activerecord.models.entity\'}})}"><i class="fa fa-exclamation"></i></a> <a if="{allowedTo(\'edit\', data.collection_id)}" href="#/entities/{data.id}" onclick="{delete}" title="{t(\'verbs.delete\')}"><i class="fa fa-trash"></i></a> </div> <h1> {data.display_name} <div class="subtitle"> <virtual if="{data.medium}"> <span class="field"> {tcap(\'activerecord.attributes.medium.original_extension\')}: </span> <span class="value">{data.medium.content_type}</span> </virtual> <span if="{!data.medium}">{data.kind.name}</span> <span if="{data.subtype}">({data.subtype})</span> </div> </h1> <div if="{data.medium}"> <span class="field"> {tcap(\'activerecord.attributes.medium.file_size\')}: </span> <span class="value">{hs(data.medium.file_size)}</span> </div> <div if="{data.synonyms.length > 0}"> <span class="field">{tcap(\'nouns.synonym\', {count: \'other\'})}:</span> <span class="value">{data.synonyms.join(\' | \')}</span> </div> <div each="{dating in data.datings}"> <span class="field">{dating.label}:</span> <span class="value">{dating.dating_string}</span> </div> <div each="{field in visibleFields()}"> <span class="field">{field.show_label}:</span> <span class="value">{fieldValue(field.value)}</span> </div> <div show="{visibleFields().length > 0}" class="hr silent"></div> <div each="{property in data.properties}"> <a if="{property.url}" href="{property.value}" rel="noopener" target="_blank">» {property.label}</a> <virtual if="{!property.url}"> <span class="field">{property.label}:</span> <span class="value">{property.value}</span> </virtual> </div> <div class="hr silent"></div> <div if="{data.comment}" class="comment"> <div class="field"> {tcap(\'activerecord.attributes.entity.comment\')}: </div> <div class="value"><pre>{data.comment}</pre></div> </div> <kor-generator each="{generator in data.generators}" generator="{generator}" entity="{data}"></kor-generator> <div class="hr silent"></div> <kor-inplace-tags entity="{data}" enable-editor="{showTagging()}" handlers="{inplaceTagHandlers}"></kor-inplace-tags> </div> <div class="kor-layout-bottom"> <div class="kor-content-box relations"> <div class="kor-layout-commands" if="{allowedTo(\'edit\')}"> <a href="#" onclick="{addRelationship}" title="{t(\'objects.add\', {interpolations: {o: \'activerecord.models.relationship\'}})}"><i class="fa fa-plus-square"></i></a> </div> <h1>{tcap(\'activerecord.models.relationship\', {count: \'other\'})}</h1> <div each="{count, name in data.relations}"> <kor-relation entity="{data}" name="{name}" total="{count}" ref="relations"></kor-relation> </div> </div> </div> <div class="kor-layout-bottom .meta" if="{allowedTo(\'view_meta\', data.collection_id)}"> <div class="kor-content-box"> <h1> {t(\'activerecord.attributes.entity.master_data\', {capitalize: true})} </h1> <div> <span class="field">{t(\'activerecord.attributes.entity.uuid\')}:</span> <span class="value">{data.uuid}</span> </div> <div if="{data.created_at}"> <span class="field">{t(\'activerecord.attributes.entity.created_at\')}:</span> <span class="value"> {l(data.created_at)} <span if="{data.creator}"> {t(\'by\')} {data.creator.full_name || data.creator.name} </span> </span> </div> <div if="{data.updated_at}"> <span class="field">{t(\'activerecord.attributes.entity.updated_at\')}:</span> <span class="value"> {l(data.updated_at)} <span if="{data.updater}"> {t(\'by\')} {data.updater.full_name || data.updater.name} </span> </span> </div> <div if="{data.groups.length}"> <span class="field">{t(\'activerecord.models.authority_group.other\')}:</span> <span class="value">{authorityGroups()}</span> </div> <div> <span class="field">{t(\'activerecord.models.collection\')}:</span> <span class="value">{data.collection.name}</span> </div> <div> <span class="field">{t(\'activerecord.attributes.entity.degree\')}:</span> <span class="value">{data.degree}</span> </div> <hr> <div class="kor-text-right kor-api-links"> <a href="/entities/{data.id}.json" target="_blank"><i class="fa fa-file-text"></i>{t(\'show_json\')}</a><br> <a href="/oai-pmh/entities.xml?verb=GetRecord&metadataPrefix=kor&identifier={data.uuid}" target="_blank"><i class="fa fa-code"></i>{t(\'show_oai_pmh\')}</a> </div> </div> </div> </div> <div class="kor-layout-right kor-layout-small"> <div class="kor-content-box" if="{data && data.medium_id}"> <div class="viewer"> <h1>{t(\'activerecord.models.medium\', {capitalize: true})}</h1> <a href="#/media/{data.id}" title="{t(\'larger\')}"> <img riot-src="{data.medium.url.preview}"> </a> <div class="commands"> <a each="{op in [\'flip\', \'flop\', \'rotate_cw\', \'rotate_ccw\', \'rotate_180\']}" href="#/media/{data.medium_id}/{op}" onclick="{transform(op)}" title="{t(\'image_transformations.\' + op)}"><i class="fa fa-{opIcon(op)}"></i></a> </div> <div class="formats"> <a href="#/media/{data.id}">{t(\'verbs.enlarge\')}</a> <span if="{!data.medium.video && !data.medium.audio}"> | <a href="{data.medium.url.normal}" target="_blank">{t(\'verbs.maximize\')}</a> </span> | <a href="{rootUrl()}mirador?id={data.id}&manifest={rootUrl()}mirador/{data.id}" onclick="{openMirador}">{t(\'nouns.mirador\')}</a> <br> {t(\'verbs.download\')}:<br> <a if="{allowedTo(\'download_originals\', data.collection_id)}" href="{data.medium.url.original.replace(/\\/images\\//, \'/download/\')}">{t(\'nouns.original\')}</a> | <a href="{data.medium.url.normal.replace(/\\/images\\//, \'/download/\')}"> {t(\'nouns.enlargement\')} </a> | <a href="/entities/{data.id}/metadata">{t(\'nouns.metadata\')}</a> </div> </div> </div> <div class="kor-content-box" if="{data}"> <div class="related_images"> <h1> {t(\'nouns.related_medium\', {count: \'other\', capitalize: true})} <div class="subtitle"> <a if="{allowedTo(\'create\')}" href="#/upload?relate_with={data.id}"> » {t(\'objects.add\', {interpolations: {o: \'activerecord.models.medium.other\'} } )} </a> </div> </h1> <div each="{count, name in data.media_relations}"> <kor-media-relation entity="{data}" name="{name}" total="{count}" on-updated="{reload}"></kor-media-relation> </div> </div> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var fetch, linkify_properties, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.info);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        wApp.bus.on("relationship-updated", fetch);
        wApp.bus.on("relationship-created", fetch);
        wApp.bus.on("relationship-deleted", fetch);
        return fetch();
    });
    tag.on("unmount", function() {
        wApp.bus.off("relationship-deleted", fetch);
        wApp.bus.off("relationship-created", fetch);
        return wApp.bus.off("relationship-updated", fetch);
    });
    tag["delete"] = function(event) {
        var message;
        event.preventDefault();
        message = tag.t("objects.confirm_destroy", {
            interpolations: {
                o: "activerecord.models.entity"
            }
        });
        if (confirm(message)) {
            return Zepto.ajax({
                type: "DELETE",
                url: "/entities/" + tag.opts.id,
                success: function() {
                    return window.history.go(-1);
                }
            });
        }
    };
    tag.visibleFields = function() {
        var f, i, len, ref, results;
        ref = tag.data.fields;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
            f = ref[i];
            if (f.value && f.show_on_entity) {
                results.push(f);
            }
        }
        return results;
    };
    tag.authorityGroups = function() {
        var g;
        return function() {
            var i, len, ref, results;
            ref = tag.data.groups;
            results = [];
            for (i = 0, len = ref.length; i < len; i++) {
                g = ref[i];
                results.push(g.name);
            }
            return results;
        }().join(", ");
    };
    tag.showTagging = function() {
        return tag.data.kind.tagging && tag.allowedTo("tagging", tag.data.collection_id);
    };
    tag.transform = function(op) {
        return function(event) {
            event.preventDefault();
            return Zepto.ajax({
                type: "PATCH",
                url: "/media/transform/" + tag.data.medium_id + "/image/" + op,
                success: function() {
                    tag.data.medium.url.preview += "?cb=" + new Date().getTime();
                    return tag.update();
                }
            });
        };
    };
    tag.opIcon = function(op) {
        return {
            flip: "arrows-v",
            flop: "arrows-h",
            rotate_cw: "mail-reply fa-flip-horizontal",
            rotate_ccw: "mail-reply",
            rotate_180: "circle-o-notch fa-flip-vertical"
        }[op];
    };
    tag.reportUrl = function() {
        var body, subject, to;
        to = wApp.config.data.values.maintainer_mail;
        subject = tag.t("messages.report_entity_subject");
        body = tag.t("messages.report_entity_body", {
            interpolations: {
                entity_url: wApp.info.data.url + "#/entities/" + tag.data.id,
                user: wApp.session.current.user.name
            }
        });
        return "mailto:" + to + "?subject=" + subject + "&body=" + encodeURIComponent(body);
    };
    tag.addRelationship = function(event) {
        event.preventDefault();
        return wApp.bus.trigger("modal", "kor-relationship-editor", {
            directedRelationship: {
                from_id: tag.data.id
            },
            onCreated: tag.reload
        });
    };
    tag.openMirador = function(event) {
        var url;
        event.preventDefault();
        event.stopPropagation();
        url = Zepto(event.target).attr("href");
        return window.open(url, "", "height=800,width=1024");
    };
    tag.fieldValue = function(value) {
        if (Zepto.isArray(value)) {
            return value.join(", ");
        } else {
            return value;
        }
    };
    fetch = function() {
        return Zepto.ajax({
            url: "/entities/" + tag.opts.id,
            data: {
                include: "all"
            },
            success: function(data) {
                var rels;
                tag.data = data;
                rels = tag.data.relations;
                tag.data.relations = {};
                tag.update();
                tag.data.relations = rels;
                tag.title(tag.data.display_name);
                linkify_properties();
                return wApp.entityHistory.add(data.id);
            },
            error: function() {
                return wApp.bus.trigger("access-denied");
            },
            complete: function() {
                return tag.update();
            }
        });
    };
    tag.inplaceTagHandlers = {
        doneHandler: fetch
    };
    linkify_properties = function() {
        var i, len, property, ref, results;
        ref = tag.data.properties;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
            property = ref[i];
            if (typeof property["value"] === "string") {
                if (property["value"].match(/^https?:\/\//)) {
                    results.push(property["url"] = true);
                } else {
                    results.push(void 0);
                }
            } else {
                results.push(void 0);
            }
        }
        return results;
    };
});

riot.tag2("kor-invalid-entities", '<div class="kor-layout-left kor-layout-large"> <div class="kor-content-box"> <h1>{tcap(\'nouns.invalid_entity\', {count: \'other\'})}</h1> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> <div class="hr"></div> <span show="{data && data.total == 0}"> {tcap(\'objects.none_found\', {interpolations: {o: \'activerecord.models.entity.other\'}})} </span> <table if="{data && data.total > 0}"> <thead> <tr> <th>{tcap(\'activerecord.attributes.entity.name\')}</th> </tr> </thead> <tbody> <tr each="{entity in data.records}"> <td> <a href="#/entities/{entity.id}" class="name">{entity.display_name}</a> <span class="kind">{entity.kind.name}</span> </td> </tr> </tbody> </table> <div class="hr"></div> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}" class="top"></kor-pagination> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var fetch, queryUpdate, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        if (tag.allowedTo("delete")) {
            fetch();
            tag.on("routing:query", fetch);
            return wApp.bus.trigger("page-title", tag.t("pages.invalid_entities"));
        } else {
            return wApp.bus.trigger("access-denied");
        }
    });
    fetch = function() {
        return Zepto.ajax({
            url: "/entities",
            data: {
                invalid: true,
                include: "kind",
                page: tag.opts.query.page,
                per_page: 20,
                sort: "id"
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
        return wApp.bus.trigger("query-update", newQuery);
    };
});

riot.tag2("kor-isolated-entities", '<div class="kor-content-box"> <h1>{tcap(\'nouns.isolated_entity\', {count: \'other\'})}</h1> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> <div class="hr"></div> <span show="{data && data.total == 0}"> {tcap(\'objects.none_found\', {interpolations: {o: \'activerecord.models.entity.other\'}})} </span> <kor-gallery-grid if="{data}" entities="{data.records}"></kor-gallery-grid> <div class="hr"></div> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> </div>', "", "", function(opts) {
    var fetch, queryUpdate, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        if (tag.allowedTo("edit")) {
            fetch();
            tag.on("routing:query", fetch);
            return tag.title(tag.t("pages.isolated_entities"));
        } else {
            return wApp.bus.trigger("access-denied");
        }
    });
    fetch = function() {
        return Zepto.ajax({
            url: "/entities",
            data: {
                include: "kind",
                isolated: true,
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
        return wApp.bus.trigger("query-update", newQuery);
    };
});

riot.tag2("kor-kind-editor", '<div class="kor-layout-left kor-layout-small"> <div class="kor-content-box"> <h1 if="{opts.id && data}"> {tcap(\'objects.edit\', {interpolations: {o: data.name}})} </h1> <h1 if="{!opts.id}"> {tcap(\'objects.create\', {interpolations: {o: \'activerecord.models.kind\'}})} </h1> <virtual if="{opts.id}"> <a href="#/kinds/{opts.id}/edit"> » {tcap(\'general\', {capitalize: true})} </a><br> </virtual> <hr if="{opts.id}"> <virtual if="{data}"> <kor-fields kind="{data}" notify="{notify}"></kor-fields> <kor-generators kind="{data}" notify="{notify}"></kor-generators> </virtual> <hr if="{opts.id}"> <div class="kor-text-right"> <a href="#/kinds" class="kor-button">{t(\'back_to_list\')}</a> </div> </div> </div> <div class="kor-layout-right kor-layout-large"> <div class="kor-content-box"> <virtual if="{!data}"> <kor-kind-general-editor></kor-kind-general-editor> </virtual> <virtual if="{data}"> <kor-kind-general-editor if="{!opts.newField && !opts.fieldId && !opts.newGenerator && !opts.generatorId}" id="{opts.id}"></kor-kind-general-editor> <kor-field-editor if="{opts.newField || opts.fieldId}" id="{opts.fieldId}" kind-id="{data.id}" notify="{notify}"></kor-field-editor> <kor-generator-editor if="{opts.newGenerator || opts.generatorId}" id="{opts.generatorId}" kind-id="{data.id}" notify="{notify}"></kor-generator-editor> </virtual> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var fetch, tag;
    tag = this;
    tag.notify = riot.observable();
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    tag.on("before-mount", function() {
        if (!tag.isKindAdmin()) {
            return wApp.bus.trigger("access-denied");
        }
    });
    tag.on("mount", function() {
        if (tag.opts.id) {
            fetch();
        }
        return tag.notify.on("refresh", fetch);
    });
    tag.on("unmount", function() {
        return tag.notify.off("refresh", fetch);
    });
    fetch = function() {
        return Zepto.ajax({
            url: "/kinds/" + tag.opts.id,
            data: {
                include: "settings,fields,generators,inheritance"
            },
            success: function(data) {
                tag.data = data;
                return tag.update();
            }
        });
    };
});

riot.tag2("kor-kind-general-editor", '<h2>{tcap(\'general\')}</h2> <div> <form if="{data && possibleParents}" onsubmit="{submit}"> <kor-input name="lock_version" riot-value="{data.lock_version || 0}" ref="fields" type="hidden"></kor-input> <kor-input name="schema" label="{tcap(\'activerecord.attributes.kind.schema\')}" riot-value="{data.schema}" ref="fields"></kor-input> <kor-input name="name" label="{tcap(\'activerecord.attributes.kind.name\')}" riot-value="{data.name}" errors="{errors.name}" ref="fields"></kor-input> <kor-input name="plural_name" label="{tcap(\'activerecord.attributes.kind.plural_name\')}" riot-value="{data.plural_name}" errors="{errors.plural_name}" ref="fields"></kor-input> <kor-input name="description" type="textarea" label="{tcap(\'activerecord.attributes.kind.description\')}" riot-value="{data.description}" ref="fields"></kor-input> <kor-input name="url" label="{tcap(\'activerecord.attributes.kind.url\')}" riot-value="{data.url}" ref="fields"></kor-input> <kor-input name="parent_ids" type="select" options="{possibleParents}" multiple="{true}" label="{tcap(\'activerecord.attributes.kind.parent\')}" riot-value="{data.parent_ids}" errors="{errors.parent_ids}" ref="fields"></kor-input> <kor-input name="abstract" type="checkbox" label="{tcap(\'activerecord.attributes.kind.abstract\')}" riot-value="{data.abstract}" ref="fields"></kor-input> <kor-input name="tagging" type="checkbox" label="{tcap(\'activerecord.attributes.kind.tagging\')}" riot-value="{data.tagging}" ref="fields"></kor-input> <div if="{!isMedia()}"> <kor-input name="dating_label" label="{tcap(\'activerecord.attributes.kind.dating_label\')}" riot-value="{data.dating_label}" ref="fields"></kor-input> <kor-input name="name_label" label="{tcap(\'activerecord.attributes.kind.name_label\')}" riot-value="{data.name_label}" ref="fields"></kor-input> <kor-input name="distinct_name_label" label="{tcap(\'activerecord.attributes.kind.distinct_name_label\')}" riot-value="{data.distinct_name_label}" ref="fields"></kor-input> </div> <div class="hr"></div> <kor-input type="submit"></kor-input> </form> </div>', "", "", function(opts) {
    var error, fetch, fetchPossibleParents, success, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        tag.errors = {};
        return fetch();
    });
    tag.isMedia = function() {
        return tag.opts.id && tag.opts.id === wApp.info.data.medium_kind_id;
    };
    tag.new_record = function() {
        return !(tag.data || {}).id;
    };
    tag.values = function() {
        var field, i, len, ref, result;
        result = {};
        ref = tag.tags["kor-input"];
        for (i = 0, len = ref.length; i < len; i++) {
            field = ref[i];
            result[field.name()] = field.value();
        }
        return result;
    };
    success = function(data) {
        route("/kinds/" + data.id + "/edit");
        wApp.bus.trigger("reload-kinds");
        tag.errors = {};
        return tag.update();
    };
    error = function(response) {
        var data;
        data = JSON.parse(response.response);
        tag.errors = data.errors;
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
                url: "/kinds/" + tag.data.id,
                data: JSON.stringify({
                    kind: tag.values()
                }),
                success: success,
                error: error
            });
        }
    };
    fetch = function() {
        if (tag.opts.id) {
            return Zepto.ajax({
                url: "/kinds/" + tag.opts.id,
                data: {
                    include: "all"
                },
                success: function(data) {
                    tag.data = data;
                    tag.update();
                    return fetchPossibleParents();
                }
            });
        } else {
            tag.data = {};
            return fetchPossibleParents();
        }
    };
    fetchPossibleParents = function() {
        return Zepto.ajax({
            url: "/kinds",
            success: function(data) {
                var i, kind, len, ref;
                tag.possibleParents = [];
                ref = data.records;
                for (i = 0, len = ref.length; i < len; i++) {
                    kind = ref[i];
                    if (!tag.data || tag.data.id !== kind.id && tag.data.id !== 1) {
                        tag.possibleParents.push({
                            label: kind.name,
                            value: kind.id
                        });
                    }
                }
                return tag.update();
            }
        });
    };
});

riot.tag2("kor-kinds", '<div class="kor-content-box"> <a if="{isKindAdmin()}" href="#/kinds/new" class="pull-right" title="{t(\'verbs.add\')}"><i class="fa fa-plus-square"></i></a> <h1>{tcap(\'activerecord.models.kind\', {count: \'other\'})}</h1> <form class="inline"> <kor-input label="{tcap(\'search_term\')}" name="terms" onkeyup="{delayedSubmit}" ref="terms"></kor-input> <kor-input label="{tcap(\'hide_abstract\')}" type="checkbox" name="hideAbstract" onchange="{submit}" ref="hideAbstract"></kor-input> </form> <div class="hr"></div> <virtual if="{filteredRecords && filteredRecords.length}"> <table each="{records, schema in groupedResults}" class="kor_table text-left"> <thead> <tr> <th>{schema == \'null\' ? tcap(\'no_schema\') : schema}</th> <th if="{isKindAdmin()}"></th> </tr> </thead> <tbody> <tr each="{kind in records}"> <td class="{active: !kind.abstract}"> <div class="name"> <a href="#/kinds/{kind.id}/edit">{kind.name}</a> </div> <div show="{kind.fields.length}"> <span class="label"> {t(\'activerecord.models.field\', {count: \'other\'})}: </span> {fieldNamesFor(kind)} </div> <div show="{kind.generators.length}"> <span class="label"> {t(\'activerecord.models.generator\', {count: \'other\'})}: </span> {generatorNamesFor(kind)} </div> </td> <td class="buttons" if="{isKindAdmin()}"> <a href="#/kinds/{kind.id}/edit" title="{t(\'verbs.edit\')}"><i class="fa fa-edit"></i></a> <a if="{kind.removable}" href="#/kinds/{kind.id}" onclick="{delete(kind)}" title="{t(\'verbs.delete\')}"><i class="fa fa-remove"></i></a> </td> </tr> </tbody> </table> </virtual>', "", "", function(opts) {
    var fetch, filter_records, groupAndSortRecords, tag, typeCompare;
    tag = this;
    tag.requireRoles = [ "kind_admin" ];
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        tag.title(tag.t("activerecord.models.kind", {
            count: "other"
        }));
        return fetch();
    });
    tag.filters = {};
    tag["delete"] = function(kind) {
        return function(event) {
            event.preventDefault();
            if (wApp.utils.confirm(tag.t("confirm.general"))) {
                return Zepto.ajax({
                    type: "DELETE",
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
        tag.filters.terms = tag.refs["terms"].value();
        tag.filters.hideAbstract = tag.refs["hideAbstract"].value();
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

riot.tag2("kor-legal", '<div class="kor-layout-left kor-layout-large"> <div class="kor-content-box"> <div class="target"></div> <div if="{!termsAccepted()}"> <div class="hr"></div> <button onclick="{submit}"> {tcap(\'commands.accept_terms\')} </button> </div> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.config);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        tag.title(tag.t("legal"));
        return Zepto(tag.root).find(".target").html(tag.config().legal_html);
    });
    tag.termsAccepted = function() {
        return tag.currentUser() && tag.currentUser().terms_accepted;
    };
    tag.submit = function() {
        return Zepto.ajax({
            url: "/users/accept_terms",
            type: "PATCH",
            success: function(data) {
                return wApp.bus.trigger("reload-session");
            }
        });
    };
});

riot.tag2("kor-login", '<kor-help-button key="login"></kor-help-button> <div class="kor-layout-left kor-layout-small"> <div class="kor-content-box"> <h1>{tcap(\'verbs.login\')}</h1> <div if="{federationAuth()}"> <div class="hr"></div> <p>{t(\'prompt.federation_login\')}</p> <a href="/env_auth" class="kor-button"> {config()[\'env_auth_button_label\']} </a> <hr> </div> <form class="form" method="POST" action="#/login" onsubmit="{submit}"> <kor-input label="{tcap(\'activerecord.attributes.user.name\')}" type="text" ref="username"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.password\')}" type="password" ref="password"></kor-input> <kor-input type="submit" label="{tcap(\'verbs.login\')}"></kor-input> </form> <a href="#/password-recovery" class="password-recovery"> {tcap(\'password_forgotten_question\')} </a> <hr> <kor-login-info></kor-login-info> </div> </div> <div class="kor-layout-right kor-layout-large"> <div class="kor-content-box"> <div class="kor-blend"></div> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.info);
    tag.mixin(wApp.mixins.config);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        return Zepto(tag.root).find("input").first().focus();
    });
    tag.submit = function(event) {
        var password, username;
        event.preventDefault();
        username = tag.refs.username.value();
        password = tag.refs.password.value();
        return wApp.auth.login(username, password).then(function() {
            var r;
            if (r = wApp.routing.query()["return_to"]) {
                return window.location.hash = decodeURIComponent(r);
            } else {
                return wApp.routing.path("/search");
            }
        });
    };
    tag.federationAuth = function() {
        var l;
        l = tag.config().env_auth_button_label;
        return typeof l === "string" && l.length > 0;
    };
});

riot.tag2("kor-medium-page", '<div class="kor-content-box"> <a if="{data}" href="#/entities/{data.id}" title="{t(\'smaller\')}"> <img if="{!data.medium.video &&! data.medium.audio}" riot-src="{data.medium.url.screen}"> <video if="{data.medium.video}" controls="true" mute autoplay> <source riot-src="{data.medium.url[\'video/mp4\']}" type="video/mp4"> <source riot-src="{data.medium.url[\'video/webm\']}" type="video/webm"> <source riot-src="{data.medium.url[\'video/ogg\']}" type="video/ogg"> </video> <audio if="{data.medium.audio}" controls="true"> <source riot-src="{data.medium.url[\'audio/mp3\']}" type="audio/mp3"> <source riot-src="{data.medium.url[\'audio/ogg\']}" type="audio/ogg"> </audio> </a> </div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        fetch();
    });
    var fetch = function() {
        Zepto.ajax({
            url: "/entities/" + tag.opts.id,
            data: {
                includes: "medium"
            },
            success: function(data) {
                tag.data = data;
                tag.update();
            }
        });
    };
});

riot.tag2("kor-new-media", '<kor-help-button key="new_entries"></kor-help-button> <div class="kor-content-box"> <h1>{tcap(\'pages.new_media\')}</h1> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}" class="top"></kor-pagination> <div class="hr"></div> <span show="{data && data.total == 0}"> {tcap(\'objects.none_found\', {interpolations: {o: \'activerecord.models.entity.other\'}})} </span> <kor-gallery-grid if="{data}" entities="{data.records}"></kor-gallery-grid> <div class="hr"></div> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> </div>', "", "", function(opts) {
    var fetch, queryUpdate, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        tag.title(tag.t("pages.new_media"));
        fetch();
        tag.on("routing:query", fetch);
        return tag.title(tag.t("pages.new_media"));
    });
    tag.on("unmount", function() {
        return tag.off("routing:query", fetch);
    });
    fetch = function() {
        return Zepto.ajax({
            url: "/entities",
            data: {
                include: "kind,gallery_data",
                page: tag.opts.query.page,
                per_page: 16,
                sort: "created_at",
                direction: "desc",
                kind_id: wApp.info.data.medium_kind_id
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
        return wApp.bus.trigger("query-update", newQuery);
    };
});

riot.tag2("kor-password-recovery", '<div class="kor-layout-left kor-layout-small"> <div class="kor-content-box"> <h1>{tcap(\'password_reset\')}</h1> <form onsubmit="{submit}"> <kor-input label="{tcap(\'prompt.email_for_personal_password_reset\')}" name="email" type="text" ref="fields"></kor-input> <div class="kor-text-right"> <kor-input type="submit" label="{tcap(\'verbs.reset\')}"></kor-input> </div> </form> <hr> <kor-login-info></kor-login-info> </div> </div> <div class="kor-layout-right kor-layout-large"> <div class="kor-content-box"> <div class="kor-blend"></div> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.submit = function(event) {
        event.preventDefault();
        var params = {
            email: tag.refs.fields.value()
        };
        var promise = Zepto.ajax({
            type: "POST",
            url: "/account-recovery",
            data: JSON.stringify(params),
            success: function(data) {
                wApp.routing.path("/login");
            }
        });
    };
});

riot.tag2("kor-profile", '<kor-help-button key="profile"></kor-help-button> <div class="kor-layout-left kor-layout-large" show="{loaded}"> <div class="kor-content-box"> <h1>{tcap(\'objects.edit\', {interpolations: {o: \'nouns.profile\'}})}</h1> <form onsubmit="{submit}" if="{data}"> <kor-input label="{tcap(\'activerecord.attributes.user.full_name\')}" name="full_name" ref="fields" riot-value="{data.full_name}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.name\')}" name="name" ref="fields" riot-value="{data.name}" errors="{errors.name}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.email\')}" name="email" ref="fields" riot-value="{data.email}" errors="{errors.email}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.password\')}" name="password" type="password" ref="fields" riot-value="{data.password}" errors="{errors.password}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.plain_password_confirmation\')}" name="plain_password_confirmation" type="password" ref="fields" errors="{errors.plain_password_confirmation}"></kor-input> <hr> <kor-input label="{tcap(\'activerecord.attributes.user.api_key\')}" name="api_key" type="textarea" ref="fields" riot-value="{data.api_key}" errors="{errors.api_key}"></kor-input> <hr> <kor-input label="{tcap(\'activerecord.attributes.user.locale\')}" name="locale" type="select" options="{[\'de\', \'en\']}" ref="fields" riot-value="{data.locale}"></kor-input> <hr> <kor-input if="{collections}" label="{tcap(\'activerecord.attributes.user.default_collection_id\')}" name="default_collection_id" type="select" options="{collections.records}" ref="fields" riot-value="{data.default_collection_id}"></kor-input> <hr> <kor-input type="submit"></kor-input> </form> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var expiresAtTag, fetchCollections, fetchUser, tag, update, values;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        tag.title(tag.t("objects.edit", {
            interpolations: {
                o: "nouns.profile"
            }
        }));
        tag.errors = {};
        if (tag.currentUser() && !tag.isGuest()) {
            return Zepto.when(fetchCollections(), fetchUser()).then(function() {
                tag.loaded = true;
                return tag.update();
            });
        } else {
            return wApp.bus.trigger("access-denied");
        }
    });
    tag.submit = function(event) {
        var p;
        event.preventDefault();
        p = update();
        p.done(function(data) {
            tag.errors = {};
            window.history.back();
            return wApp.bus.trigger("reload-session");
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
            url: "/users/me",
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
            url: "/users/me",
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

riot.tag2("kor-publishment", '<div class="kor-content-box"> <h1>{data.name}</h1> <div class="hr"></div> <kor-gallery-grid if="{data}" entities="{data.entities}" publishment="{opts.uuid}"></kor-gallery-grid> <div class="hr"></div> </div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        fetch();
    });
    var fetch = function() {
        return Zepto.ajax({
            url: "/publishments/" + tag.opts.userId + "/" + tag.opts.uuid,
            data: {
                include: "gallery_data"
            },
            success: function(data) {
                tag.data = data;
                tag.update();
            }
        });
    };
});

riot.tag2("kor-publishment-editor", '<div class="kor-layout-left kor-layout-large"> <div class="kor-content-box"> <h1 if="{opts.id}"> {tcap(\'objects.edit\', {interpolations: {o: \'activerecord.models.publishment\'}})} </h1> <h1 if="{!opts.id}"> {tcap(\'objects.create\', {interpolations: {o: \'activerecord.models.publishment\'}})} </h1> <form onsubmit="{submit}"> <kor-input label="{tcap(\'activerecord.attributes.publishment.name\')}" name="name" ref="fields" errors="{errors.name}" autofocus="{true}"></kor-input> <kor-input if="{userGroups}" label="{tcap(\'activerecord.models.user_group\')}" name="user_group_id" type="select" options="{userGroups}" ref="fields" errors="{errors.user_group}"></kor-input> <kor-input type="submit"></kor-input> </form> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var create, fetchGroups, tag, values;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.on("before-mount", function() {
        fetchGroups();
        tag.data = {};
        return tag.errors = {};
    });
    tag.submit = function(event) {
        var p;
        event.preventDefault();
        p = create();
        p.done(function(data) {
            var id;
            tag.errors = {};
            id = tag.opts.id || data.id;
            return wApp.routing.path("/groups/published");
        });
        p.fail(function(xhr) {
            tag.errors = JSON.parse(xhr.responseText).errors;
            return wApp.utils.scrollToTop();
        });
        return p.always(function() {
            return tag.update();
        });
    };
    create = function() {
        return Zepto.ajax({
            type: "POST",
            url: "/publishments",
            data: JSON.stringify({
                publishment: values()
            })
        });
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
    fetchGroups = function() {
        return Zepto.ajax({
            url: "/user_groups",
            success: function(data) {
                var i, len, record, ref;
                tag.userGroups = [];
                ref = data.records;
                for (i = 0, len = ref.length; i < len; i++) {
                    record = ref[i];
                    tag.userGroups.push({
                        value: record.id,
                        label: record.name
                    });
                }
                return tag.update();
            }
        });
    };
});

riot.tag2("kor-publishments", '<div class="kor-content-box"> <a href="#/groups/published/new" class="pull-right" title="{t(\'objects.new\', {interpolations: {o: t(\'activerecord.models.publishment\')}})}"><i class="fa fa-plus-square"></i></a> <h1>{tcap(\'activerecord.models.publishment\', {count: \'other\'})}</h1> <kor-nothing-found data="{data}" type="entity"></kor-nothing-found> <table if="{data && data.total > 0}"> <thead> <th>{tcap(\'activerecord.attributes.publishment.name\')}</th> <th>{tcap(\'activerecord.attributes.publishment.link\')}</th> <th>{tcap(\'activerecord.attributes.publishment.valid_until\')}</th> <th class="right"></th> </thead> <tbody if="{data}"> <tr each="{publishment in data.records}"> <td>{publishment.name}</td> <td> <a href="{wApp.info.data.url}#{publishment.link}" target="_blank"> {wApp.info.data.url}#{publishment.link} </a> </td> <td>{l(publishment.valid_until, \'time.formats.default\')}</td> <td class="right"> <a href="#" title="{t(\'verbs.extend\')}" onclick="{onExtendClicked}"><i class="fa fa-clock-o"></i></a> <a href="#/groups/user/{user_group_id}/destroy" onclick="{onDeleteClicked}" title="{t(\'verbs.delete\')}"><i class="fa fa-trash"></i></a> </td> </tr> </tbody> </table> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.config);
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        wApp.bus.trigger("page-title", tag.tcap("activerecord.models.publishment", {
            count: "other"
        }));
        fetch();
    });
    tag.onDeleteClicked = function(event) {
        event.preventDefault();
        var publishment = event.item.publishment;
        if (wApp.utils.confirm()) destroy(publishment.id);
    };
    tag.onExtendClicked = function(event) {
        event.preventDefault();
        var publishment = event.item.publishment;
        Zepto.ajax({
            type: "PATCH",
            url: "/publishments/" + publishment.id + "/extend",
            success: fetch
        });
    };
    var destroy = function(id) {
        Zepto.ajax({
            type: "DELETE",
            url: "/publishments/" + id,
            success: fetch
        });
    };
    var fetch = function() {
        Zepto.ajax({
            url: "/publishments",
            success: function(data) {
                tag.data = data;
                tag.update();
            }
        });
    };
});

riot.tag2("kor-recent-entities", '<div class="kor-layout-left kor-layout-small"> <div class="kor-content-box"> <h1>{tcap(\'nouns.new_entity\', {count: \'other\'})}</h1> <form onchange="{submit}" onsubmit="{submit}"> <kor-collection-selector name="collection_id" multiple="{true}" policy="view" ref="fields"></kor-collection-selector> <kor-kind-selector name="kind_id" include-media="{true}" ref="fields"></kor-kind-selector> <kor-input label="{tcap(\'activerecord.attributes.entity.created_at\')}" name="created_after" placeholder="{t(\'from\')}" help="{tcap(\'help.date_input\')}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.entity.created_at\')}" hide-label="{true}" name="created_before" placeholder="{t(\'to\')}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.entity.updated_at\')}" name="updated_after" placeholder="{t(\'from\')}" help="{tcap(\'help.date_input\')}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.entity.updated_at\')}" hide-label="{true}" name="updated_before" placeholder="{t(\'to\')}"></kor-input> <kor-user-selector label="{tcap(\'activerecord.attributes.entity.creator\')}" name="created_by" ref="fields"></kor-user-selector> <kor-user-selector label="{tcap(\'activerecord.attributes.entity.updater\')}" name="updated_by" ref="fields"></kor-user-selector> </form> </div> </div> <div class="kor-layout-right kor-layout-large"> <div class="kor-content-box"> <h1>{tcap(\'nouns.result\', {count: \'other\'})}</h1> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> <hr> <span show="{data && data.total == 0}"> {tcap(\'objects.none_found\', {interpolations: {o: \'activerecord.models.entity.other\'}})} </span> <table if="{data && data.total > 0}"> <thead> <tr> <th>{tcap(\'activerecord.attributes.entity.name\')}</th> <th>{tcap(\'activerecord.attributes.entity.collection_id\')}</th> <th> <kor-sort-by key="created_at"> {tcap(\'activerecord.attributes.entity.created_at\')} </kor-sort-by> </th> <th> <kor-sort-by key="updated_at"> {tcap(\'activerecord.attributes.entity.updated_at\')} </kor-sort-by> </th> </tr> </thead> <tbody> <tr each="{entity in data.records}"> <td> <a href="#/entities/{entity.id}" class="name">{entity.display_name}</a> <span class="kind">{entity.kind.name}</span> </td> <td>{entity.collection.name}</td> <td> {l(entity.created_at, \'time.formats.exact\')} <div>{(entity.creator || {}).full_name}</div> </td> <td> {l(entity.updated_at, \'time.formats.exact\')} <div>{(entity.updater || {}).full_name}</div> </td> </tr> </tbody> </table> <hr> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    tag.mixin(wApp.mixins.form);
    window.t = tag;
    tag.on("mount", function() {
        if (tag.allowedTo("edit")) {
            tag.title(tag.t("pages.recent_entities"));
            tag.setValues(query());
            fetch();
        } else {
            wApp.bus.trigger("access-denied");
        }
        tag.on("routing:query", queryUpdate);
    });
    tag.on("unmount", function() {
        tag.off("routing:query", queryUpdate);
    });
    var queryUpdate = function() {
        tag.setValues(query());
        fetch();
    };
    tag.pageUpdate = function(newPage) {
        wApp.routing.query({
            page: newPage
        });
    };
    tag.submit = function(event) {
        wApp.routing.query(formParams());
    };
    var defaultParams = function() {
        return {
            include: "kind,users,collection,technical",
            per_page: 10,
            date: strftime("%Y-%m-%d"),
            recent: true
        };
    };
    var formParams = function() {
        var results = tag.values();
        results["collection_id"] = wApp.utils.arrayToList(results["collection_id"]);
        return results;
    };
    var urlParams = function() {
        var results = wApp.routing.query();
        results["collection_id"] = wApp.utils.listToArray(results["collection_id"]);
        return results;
    };
    var query = function() {
        return Zepto.extend(defaultParams(), urlParams());
    };
    var fetch = function() {
        Zepto.ajax({
            url: "/entities",
            data: query(),
            success: function(data) {
                tag.data = data;
                tag.update();
            }
        });
    };
});

riot.tag2("kor-relation-editor", '<div class="kor-layout-left kor-layout-large"> <div class="kor-content-box"> <h1 if="{opts.id}"> {tcap(\'objects.edit\', {interpolations: {o: \'activerecord.models.relation\'}})} </h1> <h1 if="{!opts.id}"> {tcap(\'objects.create\', {interpolations: {o: \'activerecord.models.relation\'}})} </h1> <form onsubmit="{submit}" if="{relation && possible_parents}"> <kor-input name="lock_version" riot-value="{relation.lock_version || 0}" ref="fields" type="hidden"></kor-input> <kor-input name="schema" label="{tcap(\'activerecord.attributes.relation.schema\')}" ref="fields"></kor-input> <kor-input name="name" label="{tcap(\'activerecord.attributes.relation.name\')}" riot-value="{relation.name}" errors="{errors.name}" ref="fields"></kor-input> <kor-input name="reverse_name" label="{tcap(\'activerecord.attributes.relation.reverse_name\')}" riot-value="{relation.reverse_name}" errors="{errors.reverse_name}" ref="fields"></kor-input> <kor-input name="description" type="textarea" label="{tcap(\'activerecord.attributes.relation.description\')}" riot-value="{relation.description}" ref="fields"></kor-input> <kor-input if="{possible_kinds}" name="from_kind_id" type="select" options="{possible_kinds}" label="{tcap(\'activerecord.attributes.relation.from_kind_id\')}" riot-value="{relation.from_kind_id}" errors="{errors.from_kind_id}" ref="fields"></kor-input> <kor-input if="{possible_kinds}" name="to_kind_id" type="select" options="{possible_kinds}" label="{tcap(\'activerecord.attributes.relation.to_kind_id\')}" riot-value="{relation.to_kind_id}" errors="{errors.to_kind_id}" ref="fields"></kor-input> <kor-input name="parent_ids" type="select" options="{possible_parents}" multiple="{true}" label="{tcap(\'activerecord.attributes.relation.parent\')}" riot-value="{relation.parent_ids}" errors="{errors.parent_ids}" ref="fields"></kor-input> <kor-input name="abstract" type="checkbox" label="{tcap(\'activerecord.attributes.relation.abstract\')}" riot-value="{relation.abstract}" ref="fields"></kor-input> <div class="hr"></div> <kor-input type="submit"></kor-input> </form> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var create, fetch, fetchPossibleKinds, fetchPossibleParents, tag, update, values;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    tag.on("before-mount", function() {
        if (!tag.isRelationAdmin()) {
            return wApp.bus.trigger("access-denied");
        }
    });
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
    tag.submit = function(event) {
        var p;
        event.preventDefault();
        p = tag.opts.id ? update() : create();
        p.done(function(data) {
            tag.errors = {};
            return window.history.back();
        });
        p.fail(function(xhr) {
            tag.errors = JSON.parse(xhr.responseText).errors;
            return wApp.utils.scrollToTop();
        });
        return p.always(function() {
            return tag.update();
        });
    };
    create = function() {
        return Zepto.ajax({
            type: "POST",
            url: "/relations",
            data: JSON.stringify({
                relation: values()
            })
        });
    };
    update = function() {
        return Zepto.ajax({
            type: "PATCH",
            url: "/relations/" + tag.opts.id,
            data: JSON.stringify({
                relation: values()
            })
        });
    };
    values = function() {
        var field, i, len, ref, result;
        result = {};
        ref = tag.refs["fields"];
        for (i = 0, len = ref.length; i < len; i++) {
            field = ref[i];
            result[field.name()] = field.value();
        }
        return result;
    };
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
});

riot.tag2("kor-relations", '<div class="kor-content-box"> <div class="pull-right" if="{isRelationAdmin()}"> <a href="#" title="{t(\'verbs.merge\')}" onclick="{toggleMerge}"><i class="fa fa-compress" aria-hidden="true"></i></a> <a href="#/relations/new" title="{t(\'verbs.add\')}"><i class="fa fa-plus-square"></i></a> </div> <h1> {tcap(\'activerecord.models.relation\', {count: \'other\'})} </h1> <form class="kor-horizontal"> <kor-input name="terms" label="{tcap(\'search_term\')}" onkeyup="{delayedSubmit}"></kor-input> <div class="hr"></div> </form> <div show="{merge}"> <div class="hr"></div> <kor-relation-merger ref="merger" on-done="{mergeDone}"></kor-relation-merger> <div class="hr"></div> </div> <div if="{filteredRecords && !filteredRecords.length}"> {tcap(\'objects.none_found\', {interpolations: {o: \'activerecord.models.relation.other\'}})} </div> <table class="kor_table text-left" each="{records, schema in groupedResults}"> <thead> <tr> <th> {tcap(\'activerecord.attributes.relation.name\')} <span if="{schema == \'null\' || !schema}"> ({t(\'no_schema\')}) </span> <span if="{schema && schema != \'null\'}"> ({tcap(\'activerecord.attributes.relation.schema\')}: {schema}) </span> </th> <th> {tcap(\'activerecord.attributes.relation.from_kind_id\')}<br> {tcap(\'activerecord.attributes.relation.to_kind_id\')} </th> <th if="{isRelationAdmin()}"></th> </tr> </thead> <tbody> <tr each="{relation in records}"> <td> <a href="#/relations/{relation.id}/edit"> {relation.name} / {relation.reverse_name} </a> </td> <td> <div if="{kindLookup}"> <span class="label"> {tcap(\'activerecord.attributes.relationship.from_id\')}: </span> {kind(relation.from_kind_id)} </div> <div if="{kindLookup}"> <span class="label"> {tcap(\'activerecord.attributes.relationship.to_id\')}: </span> {kind(relation.to_kind_id)} </div> </td> <td class="kor-text-right buttons" if="{isRelationAdmin()}"> <a href="#/relations/{relation.id}/edit" title="{t(\'verbs.edit\')}"><i class="fa fa-pencil"></i></a> <a if="{merge}" href="#" onclick="{addToMerge}" title="{t(\'add_to_merge\')}"><i class="fa fa-compress"></i></a> <a href="#" onclick="{invert}" title="{t(\'verbs.invert\')}"><i class="fa fa-exchange"></i></a> <a if="{relation.removable}" href="#/relations/{relation.id}" onclick="{delete(relation)}" title="{t(\'verbs.delete\')}"><i class="fa fa-trash"></i></a> </td> </tr> </tbody> </table> </div>', "", "", function(opts) {
    var fetch, fetchKinds, filter_records, groupAndSortRecords, tag, typeCompare;
    tag = this;
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        tag.title(tag.t("activerecord.models.relation", {
            count: "other"
        }));
        fetch();
        return fetchKinds();
    });
    tag.filters = {};
    tag["delete"] = function(kind) {
        return function(event) {
            event.preventDefault();
            if (wApp.utils.confirm(tag.t("confirm.general"))) {
                return Zepto.ajax({
                    type: "DELETE",
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
        if (window.confirm(tag.t("confirm.long_time_warning"))) {
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

riot.tag2("kor-search", '<kor-help-button key="search"></kor-help-button> <div class="kor-layout-left kor-layout-small"> <div class="kor-content-box"> <h1>{tcap(\'nouns.search\')}</h1> <form onsubmit="{submit}"> <kor-collection-selector name="collection_id" multiple="{true}" riot-value="{criteria.collection_id}" policy="view" ref="fields"></kor-collection-selector> <kor-kind-selector name="kind_id" riot-value="{criteria.kind_id}" ref="fields" onchange="{selectKind}" include-media="{true}"></kor-kind-selector> <kor-input if="{elastic()}" name="terms" label="{tcap(\'all_fields\')}" riot-value="{criteria.terms}" ref="fields" help="{tcap(\'help.terms_query\')}"></kor-input> <kor-input name="name" label="{tcap(\'activerecord.attributes.entity.name\')}" riot-value="{criteria.name}" ref="fields" help="{tcap(\'help.name_query\')}"></kor-input> <kor-input name="tags" label="{tcap(\'nouns.tag\', {count: \'other\'})}" riot-value="{criteria.tags}" ref="fields"></kor-input> <kor-input name="dating" label="{tcap(\'activerecord.models.entity_dating\')}" riot-value="{criteria.dating}" ref="fields" help="{tcap(\'help.dating_query\')}"></kor-input> <virtual if="{isMedia(kind)}"> <hr> <kor-input name="file_name" label="{tcap(\'activerecord.attributes.medium.file_name\')}" riot-value="{criteria.file_name}" ref="fields"></kor-input> <kor-input if="{mime_types}" name="file_type" label="{tcap(\'activerecord.attributes.medium.file_type\')}" type="select" options="{mime_types}" placeholder="{t(\'all\')}" riot-value="{criteria.file_type}" ref="fields"></kor-input> <kor-input name="file_size" label="{tcap(\'activerecord.attributes.medium.file_size\')}" riot-value="{criteria.file_size}" ref="fields" help="{tcap(\'help.file_size_query\')}"></kor-input> <kor-input name="datahash" label="{tcap(\'activerecord.attributes.medium.datahash\')}" riot-value="{criteria.datahash}" ref="fields"></kor-input> </virtual> <virtual if="{elastic()}"> <virtual if="{kind && kind.fields.length}"> <hr> <kor-input each="{field in kind.fields}" label="{field.search_label}" name="dataset_{field.name}" riot-value="{criteria[\'dataset_\' + field.name]}" ref="fields"></kor-input> </virtual> <hr> <kor-input name="property" label="{tcap(\'activerecord.attributes.entity.properties\')}" riot-value="{criteria.property}" ref="fields"></kor-input> <kor-input name="related" label="{tcap(\'by_related_entities\')}" riot-value="{criteria.related}" ref="fields"></kor-input> </virtual> <div class="kor-text-right"> <kor-input type="submit" label="{tcap(\'verbs.search\')}"></kor-input> </div> </form> </div> </div> <div class="kor-layout-right kor-layout-large"> <div class="kor-content-box"> <h1>{tcap(\'nouns.search_results\')}</h1> </div> <kor-nothing-found data="{data}" type="entity"></kor-nothing-found> <div class="search-results" if="{data && data.total > 0}"> <kor-pagination page="{data.page}" per-page="{data.per_page}" total="{data.total}" on-paginate="{page}" class="top"></kor-pagination> <div class="kor-search-results"> <kor-search-result each="{entity in data.records}" entity="{entity}"></kor-search-result> </div> <kor-pagination page="{data.page}" per-page="{data.per_page}" total="{data.total}" on-paginate="{page}" class="bottom"></kor-pagination> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.on("before-mount", function() {
        fetchMimeTypes();
        tag.criteria = urlParams();
    });
    tag.on("mount", function() {
        tag.title(tag.t("nouns.search"));
        tag.on("routing:query", queryUpdate);
        queryUpdate();
    });
    tag.on("unmount", function() {
        tag.off("routing:query", queryUpdate);
    });
    var queryUpdate = function() {
        tag.criteria = urlParams();
        tag.update();
        if (tag.criteria["kind_id"]) {
            fetchKind(tag.criteria["kind_id"]);
        }
        tag.tags["kor-collection-selector"].reset();
        fetch();
    };
    tag.submit = function(event) {
        event.preventDefault();
        wApp.routing.query(params(), true);
    };
    tag.page = function(newPage) {
        wApp.routing.query({
            page: newPage
        });
    };
    tag.selectKind = function(event) {
        var id = Zepto(event.target).val();
        if (id && id != "0") {
            fetchKind(id);
            wApp.routing.query({
                kind_id: id
            });
        } else {
            tag.kind = null;
            tag.update();
        }
    };
    tag.elastic = function() {
        return wApp.info.data.elastic;
    };
    tag.isMedia = function(kind) {
        if (!kind) {
            return false;
        }
        return kind.id === wApp.info.data.medium_kind_id;
    };
    var params = function() {
        var results = {
            page: 1
        };
        for (var i = 0; i < tag.refs.fields.length; i++) {
            var f = tag.refs.fields[i];
            var v = f.value();
            if (v != "" && v != [] && v != undefined) {
                if (Zepto.isArray(v)) {
                    results[f.name()] = v.join(",");
                } else {
                    results[f.name()] = v;
                }
            }
        }
        return results;
    };
    var urlParams = function() {
        var results = wApp.routing.query();
        results["collection_id"] = wApp.utils.toIdArray(results["collection_id"]);
        return results;
    };
    var fetchKind = function(id) {
        Zepto.ajax({
            url: "/kinds/" + id,
            data: {
                include: "fields"
            },
            success: function(data) {
                tag.kind = data;
                tag.update();
            }
        });
    };
    var fetchMimeTypes = function() {
        Zepto.ajax({
            url: "/statistics",
            success: function(data) {
                tag.mime_types = Object.keys(data.mime_counts).sort();
                tag.update();
            }
        });
    };
    var fetch = function() {
        var params = Zepto.extend({}, tag.criteria, {
            include: "related",
            related_kind_id: wApp.info.data.medium_kind_id,
            related_per_page: 4
        });
        Zepto.ajax({
            url: "/entities",
            data: params,
            success: function(data) {
                tag.data = data;
                tag.update();
            }
        });
    };
});

riot.tag2("kor-settings-editor", '<div class="kor-layout-left kor-layout-large"> <div class="kor-content-box"> <h1> {tcap(\'activerecord.models.setting\', {count: \'other\'})} </h1> <form onsubmit="{submit}" if="{values && groups && relations}"> <h2>{tcap(\'settings.branding_and_display\')}</h2> <hr> <kor-input name="maintainer_name" label="{nameFor(\'maintainer_name\')}" riot-value="{valueWithDefaults(\'maintainer_name\')}" ref="fields"></kor-input> <kor-input name="maintainer_mail" label="{nameFor(\'maintainer_mail\')}" riot-value="{valueWithDefaults(\'maintainer_mail\')}" ref="fields"></kor-input> <kor-input name="welcome_title" label="{nameFor(\'welcome_title\')}" riot-value="{valueWithDefaults(\'welcome_title\')}" ref="fields"></kor-input> <kor-input name="welcome_text" label="{nameFor(\'welcome_text\')}" type="textarea" riot-value="{valueWithDefaults(\'welcome_text\')}" ref="fields"></kor-input> <kor-input name="legal_text" label="{nameFor(\'legal_text\')}" type="textarea" riot-value="{valueWithDefaults(\'legal_text\')}" ref="fields"></kor-input> <kor-input name="about_text" label="{nameFor(\'about_text\')}" type="textarea" riot-value="{valueWithDefaults(\'about_text\')}" ref="fields"></kor-input> <kor-input name="custom_css_file" label="{nameFor(\'custom_css_file\')}" riot-value="{valueWithDefaults(\'custom_css_file\')}" ref="fields"></kor-input> <kor-input name="env_auth_button_label" label="{nameFor(\'env_auth_button_label\')}" riot-value="{valueWithDefaults(\'env_auth_button_label\')}" ref="fields"></kor-input> <kor-input name="search_entity_name" label="{nameFor(\'search_entity_name\')}" riot-value="{valueWithDefaults(\'search_entity_name\')}" ref="fields"></kor-input> <kor-input name="kind_dating_label" label="{nameFor(\'kind_dating_label\')}" riot-value="{valueWithDefaults(\'kind_dating_label\')}" ref="fields"></kor-input> <kor-input name="kind_name_label" label="{nameFor(\'kind_name_label\')}" riot-value="{valueWithDefaults(\'kind_name_label\')}" ref="fields"></kor-input> <kor-input name="kind_distinct_name_label" label="{nameFor(\'kind_distinct_name_label\')}" riot-value="{valueWithDefaults(\'kind_distinct_name_label\')}" ref="fields"></kor-input> <kor-input name="relationship_dating_label" label="{nameFor(\'relationship_dating_label\')}" riot-value="{valueWithDefaults(\'relationship_dating_label\')}" ref="fields"></kor-input> <kor-input name="primary_relations" label="{nameFor(\'primary_relations\')}" type="select" multiple="{true}" options="{relations}" riot-value="{valueWithDefaults(\'primary_relations\')}" ref="fields"></kor-input> <kor-input name="secondary_relations" label="{nameFor(\'secondary_relations\')}" type="select" multiple="{true}" options="{relations}" riot-value="{valueWithDefaults(\'secondary_relations\')}" ref="fields"></kor-input> <h2>{tcap(\'settings.behavior\')}</h2> <hr> <kor-input name="default_locale" label="{nameFor(\'default_locale\')}" type="select" options="{wApp.i18n.locales()}" riot-value="{valueWithDefaults(\'default_locale\')}" ref="fields"></kor-input> <kor-input name="max_foreground_group_download_size" label="{nameFor(\'max_foreground_group_download_size\')}" riot-value="{valueWithDefaults(\'max_foreground_group_download_size\')}" ref="fields" type="number"></kor-input> <kor-input name="max_file_upload_size" label="{nameFor(\'max_file_upload_size\')}" riot-value="{valueWithDefaults(\'max_file_upload_size\')}" ref="fields" type="number"></kor-input> <kor-input name="max_results_per_request" label="{nameFor(\'max_results_per_request\')}" riot-value="{valueWithDefaults(\'max_results_per_request\')}" ref="fields" type="number"></kor-input> <kor-input name="max_included_results_per_result" label="{nameFor(\'max_included_results_per_result\')}" riot-value="{valueWithDefaults(\'max_included_results_per_result\')}" ref="fields" type="number"></kor-input> <kor-input name="session_lifetime" label="{nameFor(\'session_lifetime\')}" riot-value="{valueWithDefaults(\'session_lifetime\')}" ref="fields" type="number"></kor-input> <kor-input name="publishment_lifetime" label="{nameFor(\'publishment_lifetime\')}" riot-value="{valueWithDefaults(\'publishment_lifetime\')}" ref="fields" type="number"></kor-input> <kor-input name="default_groups" label="{nameFor(\'default_groups\')}" type="select" multiple="{true}" options="{groups}" riot-value="{valueWithDefaults(\'default_groups\')}" ref="fields"></kor-input> <kor-input name="max_download_group_size" label="{nameFor(\'max_download_group_size\')}" riot-value="{valueWithDefaults(\'max_download_group_size\')}" ref="fields" type="number"></kor-input> <kor-input name="mirador_page_template" label="{nameFor(\'mirador_page_template\')}" riot-value="{valueWithDefaults(\'mirador_page_template\')}" ref="fields" type="number"></kor-input> <kor-input name="mirador_manifest_template" label="{nameFor(\'mirador_page_template\')}" riot-value="{valueWithDefaults(\'mirador_manifest_template\')}" ref="fields" type="number"></kor-input> <h2>{tcap(\'settings.help\')}</h2> <hr> <kor-input name="help_general" label="{nameFor(\'help_general\')}" type="textarea" riot-value="{valueWithDefaults(\'help_general\')}" ref="fields"></kor-input> <kor-input name="help_search" type="textarea" label="{nameFor(\'help_search\')}" riot-value="{valueWithDefaults(\'help_search\')}" ref="fields"></kor-input> <kor-input name="help_upload" type="textarea" label="{nameFor(\'help_upload\')}" riot-value="{valueWithDefaults(\'help_upload\')}" ref="fields"></kor-input> <kor-input name="help_login" type="textarea" label="{nameFor(\'help_login\')}" riot-value="{valueWithDefaults(\'help_login\')}" ref="fields"></kor-input> <kor-input name="help_profile" type="textarea" label="{nameFor(\'help_profile\')}" riot-value="{valueWithDefaults(\'help_profile\')}" ref="fields"></kor-input> <kor-input name="help_new_entries" type="textarea" label="{nameFor(\'help_new_entries\')}" riot-value="{valueWithDefaults(\'help_entries\')}" ref="fields"></kor-input> <kor-input name="help_authority_groups" type="textarea" label="{nameFor(\'help_authority_groups\')}" riot-value="{valueWithDefaults(\'help_authority_groups\')}" ref="fields"></kor-input> <kor-input name="help_user_groups" type="textarea" label="{nameFor(\'help_user_groups\')}" riot-value="{valueWithDefaults(\'help_user_groups\')}" ref="fields"></kor-input> <kor-input name="help_clipboard" type="textarea" label="{nameFor(\'help_clipboard\')}" riot-value="{valueWithDefaults(\'help_clipboard\')}" ref="fields"></kor-input> <h2>{tcap(\'settings.other\')}</h2> <hr> <kor-input name="sources_release" label="{nameFor(\'sources_release\')}" riot-value="{valueWithDefaults(\'sources_release\')}" ref="fields"></kor-input> <kor-input name="sources_pre_release" label="{nameFor(\'sources_pre_release\')}" riot-value="{valueWithDefaults(\'sources_pre_release\')}" ref="fields"></kor-input> <kor-input name="sources_default" label="{nameFor(\'sources_default\')}" riot-value="{valueWithDefaults(\'sources_default\')}" ref="fields"></kor-input> <kor-input name="repository_uuid" label="{nameFor(\'repository_uuid\')}" riot-value="{valueWithDefaults(\'repository_uuid\')}" ref="fields"></kor-input> <kor-input type="submit"></kor-input> </form> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var fetch, fetchGroups, fetchRelations, tag, update, values;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.errors = {};
    tag.on("mount", function() {
        tag.title(tag.t("activerecord.models.setting", {
            count: "other"
        }));
        fetch();
        fetchGroups();
        return fetchRelations();
    });
    tag.valueWithDefaults = function(key) {
        return tag.values[key];
    };
    tag.nameFor = function(key) {
        return tag.tcap("settings.values." + key);
    };
    tag.submit = function(event) {
        var p;
        event.preventDefault();
        p = update();
        p.done(function(data) {
            return tag.errors = {};
        });
        p.fail(function(xhr) {
            return tag.errors = JSON.parse(xhr.responseText).errors;
        });
        return p.always(function() {
            tag.update();
            return wApp.utils.scrollToTop();
        });
    };
    update = function() {
        return Zepto.ajax({
            type: "PATCH",
            url: "/settings",
            data: JSON.stringify({
                settings: values(),
                mtime: tag.mtime
            }),
            success: function(data) {
                return wApp.bus.trigger("config-updated");
            }
        });
    };
    values = function() {
        var field, i, len, ref, result;
        result = {};
        ref = tag.refs["fields"];
        for (i = 0, len = ref.length; i < len; i++) {
            field = ref[i];
            result[field.name()] = field.value();
        }
        return result;
    };
    fetch = function() {
        return Zepto.ajax({
            url: "/settings",
            success: function(data) {
                tag.values = data.values;
                tag.defaults = data.defaults;
                tag.mtime = data.mtime;
                return tag.update();
            }
        });
    };
    fetchGroups = function() {
        return Zepto.ajax({
            url: "/credentials",
            success: function(data) {
                tag.groups = data.records;
                return tag.update();
            },
            error: function() {
                return wApp.bus.trigger("access-denied");
            }
        });
    };
    fetchRelations = function() {
        return Zepto.ajax({
            url: "/relations/names",
            success: function(data) {
                tag.relations = data;
                return tag.update();
            }
        });
    };
});

riot.tag2("kor-statistics", "<div class=\"kor-layout-left kor-layout-large\"> <div class=\"kor-content-box\"> <h1>{tcap('nouns.statistics')}</h1> <p if=\"{data}\">{validity()}</p> <table if=\"{data}\"> <thead> <tr> <th>{tcap('activerecord.models.user', {count: 'other'})}</th> <th>{data.user_count}</th> </tr> </thead> <tbody> <tr> <td>{tcap('logged_in_recently')}</td> <td>{data.user_count_logged_in_recently}</td> </tr> <tr> <td>{tcap('logged_in_last_year')}</td> <td>{data.user_count_logged_in_last_year}</td> </tr> <tr> <td>{tcap('created_recently')}</td> <td>{data.user_count_created_recently}</td> </tr> </tbody> </table> <table if=\"{data}\"> <thead> <tr> <th>{tcap('activerecord.models.entity', {count: 'other'})}</th> <th>{data.entity_count}</th> </tr> </thead> <tbody> <tr each=\"{stat in data.entities_by_kind}\"> <td>{stat.kind_name}</td> <td>{stat.count}</td> </tr> </tbody> </table> <table if=\"{data}\"> <thead> <tr> <th>{tcap('activerecord.models.relationship', {count: 'other'})}</th> <th>{data.relationship_count}</th> </tr> </thead> <tbody> <tr each=\"{stat in data.relationships_by_relation}\"> <td>{stat.relation_name}</td> <td>{stat.count}</td> </tr> </tbody> </table> </div> </div> <div class=\"kor-layout-right\"></div> <div class=\"clearfix\"></div>", "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        tag.title(tag.t("nouns.statistics"));
        fetch();
    });
    tag.validity = function() {
        return tag.t("messages.statistics_validity", {
            interpolations: {
                date: tag.l(tag.data.timestamp, "time.formats.exact")
            }
        });
    };
    var fetch = function() {
        Zepto.ajax({
            url: "/statistics",
            success: function(data) {
                tag.data = data;
                tag.update();
            }
        });
    };
});

riot.tag2("kor-upload", '<kor-help-button key="upload"></kor-help-button> <div class="kor-layout-left kor-layout-small"> <div class="kor-content-box"> <h1>{tcap(\'verbs.upload\')}</h1> <form onsubmit="{submit}"> <kor-collection-selector policy="create" ref="cs"></kor-collection-selector> <kor-entity-group-selector type="user" riot-value="{l(new Date())}" ref="group"></kor-entity-group-selector> <div if="{selection}"> {tcap(\'labels.relate_to_via\', {interpolations: {to: selection.display_name}})}: <kor-relation-selector if="{selection}" source-kind-id="{wApp.info.data.medium_kind_id}" target-kind-id="{selection.kind_id}" ref="relation-selector"></kor-relation-selector> </div> <a class="trigger"> » {tcap(\'objects.add\', {interpolations: {o: \'nouns.file.other\'}})} </a> </form> </div> </div> <div class="kor-layout-right kor-layout-large"> <div class="kor-content-box"> <ul> <li each="{job in files()}"> <div class="pull-right"> <a ref="#" onclick="{remove}">x</a> </div> <strong>{job.name}</strong> <div> {hs(job.size)} <span show="{job.percent > 0}"> <span show="{job.percent < 100}"> {job.percent} </span> <span show="{job.percent == 100 && !job.error}"> ... {t(\'done\')} </span> </span> <div class="kor-error" if="{job.error}"> <strong>{job.error.parsed_response.message}: <div each="{errors, field in job.error.parsed_response.errors}"> <span>{errors.join(\', \')}</span> </div> </strong> </div> </div> </li> </ul> <form class="inline" onsubmit="{submit}"> <div class="kor-text-right"> <kor-input type="submit" label="{tcap(\'verbs.upload\')}"></kor-input> <kor-input type="submit" label="{tcap(\'empty_list\')}" onclick="{abort}"></kor-input> </div> </form> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    var uploader = null;
    tag.on("mount", function() {
        tag.title(tag.t("verbs.upload"));
        init();
    });
    tag.files = function() {
        if (uploader) return uploader.files; else return [];
    };
    tag.remove = function(event) {
        event.preventDefault();
        uploader.removeFile(event.item.job);
    };
    tag.abort = function(event) {
        event.preventDefault();
        uploader.stop();
        uploader.splice(0, uploader.files.length);
    };
    tag.submit = function(event) {
        event.preventDefault();
        var params = {
            "entity[kind_id]": wApp.info.data.medium_kind_id,
            "entity[collection_id]": tag.refs["cs"].value(),
            user_group_name: tag.refs["group"].value(),
            target_entity_id: wApp.clipboard.selection(),
            authenticity_token: wApp.session.csrfToken()
        };
        var rs = tag.refs["relation-selector"];
        if (rs) {
            params["relation_name"] = rs.value();
        }
        uploader.setOption("multipart_params", params);
        uploader.start();
    };
    tag.hasSelection = function() {
        return !!wApp.clipboard.selection();
    };
    var relationSelectorValue = function() {
        return tag.refs["relation-selector"] ? tag.refs["relation-selector"].value() : nil;
    };
    var fetchSelected = function(id) {
        Zepto.ajax({
            url: "/entities/" + id,
            success: function(data) {
                tag.selection = data;
                tag.update();
                tag.refs["relation-selector"].trigger("endpoints-changed");
            },
            error: function(xhr, reason) {
                if (xhr.status == 404) {
                    wApp.clipboard.unselect();
                    tag.update();
                } else console.log(xhr, reason);
            }
        });
    };
    var init = function() {
        if (tag.hasSelection()) fetchSelected(wApp.clipboard.selection());
        var id = wApp.routing.query()["relate_with"];
        if (id) fetchSelected(id);
        uploader = new plupload.Uploader({
            browse_button: Zepto(".trigger")[0],
            url: "/entities",
            headers: {
                accept: "application/json"
            },
            file_data_name: "entity[medium_attributes][document]"
        });
        uploader.bind("QueueChanged", function(up) {
            tag.update();
        });
        uploader.bind("UploadProgress", function(up, file) {
            tag.update();
        });
        uploader.bind("FileUploaded", function(up, file, response) {
            var doit = function() {
                uploader.removeFile(file);
            };
            setTimeout(doit, 300);
        });
        uploader.bind("Error", function(up, error) {
            if (error.code == -600) {
                var message = tag.t("messages.file_too_big", {
                    interpolations: {
                        file: error.file.name,
                        size: (error.file.origSize / 1024 / 1024).toFixed(2),
                        max: scope.max_file_size()
                    }
                });
                window.alert(message);
            } else {
                error.parsed_response = JSON.parse(error.response);
                error.file.error = error;
                tag.update();
            }
        });
        uploader.init();
    };
});

riot.tag2("kor-user-editor", '<div class="kor-layout-left kor-layout-large" show="{loaded}"> <div class="kor-content-box"> <h1 show="{opts.id}"> {tcap(\'objects.edit\', {interpolations: {o: \'activerecord.models.user\'}})} </h1> <h1 show="{!opts.id}"> {tcap(\'objects.new\', {interpolations: {o: \'activerecord.models.user\'}})} </h1> <form onsubmit="{submit}" if="{data}"> <kor-input name="lock_version" riot-value="{data.lock_version || 0}" ref="fields" type="hidden"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.personal\')}" name="make_personal" type="checkbox" ref="fields" riot-value="{data.personal}" errors="{errors.make_personal}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.full_name\')}" name="full_name" ref="fields" riot-value="{data.full_name}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.name\')}" name="name" ref="fields" riot-value="{data.name}" errors="{errors.name}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.email\')}" name="email" ref="fields" riot-value="{data.email}" errors="{errors.email}"></kor-input> <div class="hr"></div> <kor-input label="{tcap(\'activerecord.attributes.user.api_key\')}" name="api_key" type="textarea" ref="fields" riot-value="{data.api_key}" errors="{errors.api_key}"></kor-input> <div class="hr"></div> <kor-input label="{tcap(\'activerecord.attributes.user.active\')}" name="active" type="checkbox" ref="fields" riot-value="{data.active}"></kor-input> <div class="expires-at"> <kor-input label="{tcap(\'activerecord.attributes.user.expires_at\')}" name="expires_at" ref="fields" riot-value="{valueForDate(data.expires_at)}" errors="{errors.expires_at}" type="{\'date\'}"></kor-input> <button onclick="{expiresIn(0)}"> {tcap(\'activerecord.attributes.user.does_not_expire\')} </button> <button onclick="{expiresIn(7)}"> {tcap(\'activerecord.attributes.user.expires_in_days\', {interpolations: {amount: 7}})} </button> <button onclick="{expiresIn(30)}"> {tcap(\'activerecord.attributes.user.expires_in_days\', {interpolations: {amount: 30}})} </button> <button onclick="{expiresIn(180)}"> {tcap(\'activerecord.attributes.user.expires_in_days\', {interpolations: {amount: 180}})} </button> <div class="clearfix"></div> </div> <div class="hr"></div> <kor-input label="{tcap(\'activerecord.attributes.user.parent_username\')}" name="parent_username" type="text" ref="fields" riot-value="{data.parent_username}" errors="{errors.parent_username}"></kor-input> <div class="hr"></div> <kor-input if="{credentials}" label="{tcap(\'activerecord.attributes.user.groups\')}" name="group_ids" type="select" options="{credentials.records}" multiple="{true}" ref="fields" riot-value="{data.group_ids}"></kor-input> <div class="hr"></div> <kor-input label="{tcap(\'activerecord.attributes.user.authority_group_admin\')}" name="authority_group_admin" type="checkbox" ref="fields" riot-value="{data.authority_group_admin}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.relation_admin\')}" name="relation_admin" type="checkbox" ref="fields" riot-value="{data.relation_admin}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.kind_admin\')}" name="kind_admin" type="checkbox" ref="fields" riot-value="{data.kind_admin}"></kor-input> <kor-input label="{tcap(\'activerecord.attributes.user.admin\')}" name="admin" type="checkbox" ref="fields" riot-value="{data.admin}"></kor-input> <div class="hr"></div> <kor-input type="submit"></kor-input> </form> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var create, expiresAtTag, fetchCredentials, fetchUser, tag, update, values;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        tag.errors = {};
        if (tag.isAdmin()) {
            return Zepto.when(fetchCredentials(), fetchUser()).then(function() {
                tag.loaded = true;
                return tag.update();
            });
        } else {
            return wApp.bus.trigger("access-denied");
        }
    });
    tag.submit = function(event) {
        var p;
        event.preventDefault();
        p = tag.opts.id ? update() : create();
        p.done(function(data) {
            return wApp.routing.path("/users");
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
            event.preventDefault();
            if (days) {
                date = new Date();
                date = new Date(date.getTime() + days * 24 * 60 * 60 * 1e3);
                return expiresAtTag().set([ date.getUTCFullYear(), ("00" + (date.getUTCMonth() + 1)).substr(-2, 2), ("00" + date.getUTCDate()).substr(-2, 2) ].join("-"));
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
                    include: "all"
                },
                success: function(data) {
                    tag.data = data;
                    return tag.update();
                }
            });
        } else {
            tag.data = {
                lock_version: 0
            };
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

riot.tag2("kor-user-group-editor", '<div class="kor-layout-left kor-layout-large"> <div class="kor-content-box"> <h1 if="{opts.id}"> {tcap(\'objects.edit\', {interpolations: {o: \'activerecord.models.user_group\'}})} </h1> <h1 if="{!opts.id}"> {tcap(\'objects.create\', {interpolations: {o: \'activerecord.models.user_group\'}})} </h1> <form onsubmit="{submit}" if="{data}"> <kor-input label="{tcap(\'activerecord.attributes.user_group.name\')}" name="name" ref="fields" riot-value="{data.name}" errors="{errors.name}"></kor-input> <hr> <kor-input type="submit"></kor-input> </form> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var create, fetch, tag, update, values;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.on("before-mount", function() {
        tag.errors = {};
        return tag.data = {};
    });
    tag.on("mount", function() {
        if (tag.opts.id) {
            return fetch();
        }
    });
    tag.submit = function(event) {
        var p;
        event.preventDefault();
        p = tag.opts.id ? update() : create();
        p.done(function(data) {
            tag.errors = {};
            return window.history.back();
        });
        p.fail(function(xhr) {
            tag.errors = JSON.parse(xhr.responseText).errors;
            return wApp.utils.scrollToTop();
        });
        return p.always(function() {
            return tag.update();
        });
    };
    fetch = function() {
        return Zepto.ajax({
            url: "/user_groups/" + tag.opts.id,
            success: function(data) {
                tag.data = data;
                return tag.update();
            }
        });
    };
    create = function() {
        return Zepto.ajax({
            type: "POST",
            url: "/user_groups",
            data: JSON.stringify({
                user_group: values()
            })
        });
    };
    update = function() {
        return Zepto.ajax({
            type: "PATCH",
            url: "/user_groups/" + tag.opts.id,
            data: JSON.stringify({
                user_group: values()
            })
        });
    };
    values = function() {
        return {
            name: tag.refs.fields.value()
        };
    };
});

riot.tag2("kor-user-groups", '<kor-help-button key="user_groups"></kor-help-button> <div class="kor-layout-left kor-layout-large"> <div class="kor-content-box"> <a if="{!opts.type}" href="#/groups/user/new" class="pull-right" title="{t(\'objects.new\', {interpolations: {o: t(\'activerecord.models.user_group\')}})}"><i class="fa fa-plus-square"></i></a> <h1> <virtual if="{!opts.type}">{tcap(\'activerecord.models.user_group\', {count: \'other\'})}</virtual> <virtual if="{opts.type == \'shared\'}">{tcap(\'nouns.shared_user_group\')}</virtual> </h1> <kor-nothing-found data="{data}"></kor-nothing-found> <table if="{data && data.total > 0}"> <thead> <th>{tcap(\'activerecord.attributes.user_group.name\')}</th> <th if="{opts.type == \'shared\'}">{tcap(\'activerecord.attributes.user_group.owner\')}</th> <th class="right"></th> </thead> <tbody if="{data}"> <tr each="{user_group in data.records}"> <td> <a href="#/groups/user/{user_group.id}">{user_group.name}</a> </td> <td if="{opts.type == \'shared\'}"> {user_group.owner.display_name} </td> <td class="right"> <virtual if="{mine(user_group)}"> <a href="#/groups/user/{user_group.id}/edit" title="{t(\'verbs.edit\')}"><i class="fa fa-pencil"></i></a> <a href="#/groups/user/{user_group.id}/destroy" onclick="{onDeleteClicked}" title="{t(\'verbs.delete\')}"><i class="fa fa-trash"></i></a> <a href="#/groups/user/{user_group.id}/share" onclick="{onShareClicked}" title="{t(\'verbs.\' + (user_group.shared ? \'unshare\' : \'share\'))}"><i class="{\'fa fa-lock\': !user_group.shared, \'fa fa-unlock\': user_group.shared}"></i></a> </virtual> </td> </tr> </tbody> </table> </div> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.config);
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        if (tag.opts.type == "shared") {
            tag.title(tag.tcap("nouns.shared_user_group"));
        } else {
            tag.title(tag.tcap("activerecord.models.user_group"));
        }
        fetch();
    });
    tag.onDeleteClicked = function(event) {
        event.preventDefault();
        if (wApp.utils.confirm()) destroy(event.item.user_group.id);
    };
    tag.onShareClicked = function(event) {
        event.preventDefault();
        var group = event.item.user_group;
        var verb = group.shared ? "unshare" : "share";
        Zepto.ajax({
            type: "PATCH",
            url: "/user_groups/" + group.id + "/" + verb,
            success: fetch
        });
    };
    tag.mine = function(group) {
        return group.user_id == tag.session().user.id;
    };
    var destroy = function(id) {
        Zepto.ajax({
            type: "DELETE",
            url: "/user_groups/" + id,
            success: fetch
        });
    };
    var fetch = function() {
        Zepto.ajax({
            url: tag.opts.type == "shared" ? "/user_groups/shared" : "user_groups",
            data: {
                include: "owner"
            },
            success: function(data) {
                tag.data = data;
                tag.update();
            }
        });
    };
});

riot.tag2("kor-users", '<div class="kor-content-box"> <div class="kor-layout-commands"> <a href="#/users/new" title="{t(\'verbs.add\')}"><i class="fa fa-plus-square"></i></a> </div> <h1>{tcap(\'activerecord.models.user\', {count: \'other\'})}</h1> <form onsubmit="{search}" class="inline"> <kor-input label="{t(\'nouns.search\')}" ref="search" riot-value="{opts.query.search}"></kor-input> </form> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> <div class="hr"></div> <span show="{data && data.total == 0}"> {tcap(\'objects.none_found\', {interpolations: {o: \'nouns.entity.one\'}})} </span> <table if="{data}"> <thead> <tr> <th class="tiny">{t(\'activerecord.attributes.user.personal\')}</th> <th class="small">{t(\'activerecord.attributes.user.name\')}</th> <th class="small">{t(\'activerecord.attributes.user.full_name\')}</th> <th>{t(\'activerecord.attributes.user.email\')}</th> <th class="tiny right"> {t(\'activerecord.attributes.user.created_at\')} </th> <th class="tiny right"> {t(\'activerecord.attributes.user.last_login\')} </th> <th class="tiny right"> {t(\'activerecord.attributes.user.expires_at\')} </th> <th class="tiny buttons"></th> </tr> </thead> <tbody> <tr each="{user in data.records}"> <td><i show="{user.personal}" class="fa fa-check"></i></td> <td>{user.name}</td> <td>{user.full_name}</td> <td class="force-wrap"> <a href="mailto:{user.email}">{user.email}</a> </td> <td class="right">{l(user.created_at)}</td> <td class="right">{l(user.last_login)}</td> <td class="right">{l(user.expires_at)}</td> <td class="right nobreak"> <a onclick="{resetLoginAttempts(user.id)}" title="{t(\'reset_login_attempts\')}"><i class="fa fa-unlock"></i></a> <a if="{user.name != \'admin\' && user.name != \'guest\'}" href="#" onclick="{resetPassword(user.id)}" title="{t(\'reset_password\')}"><i class="fa fa-key"></i></a> <a href="#/users/{user.id}/edit" title="{t(\'verbs.edit\')}"><i class="fa fa-pencil"></i></a> <a href="#" onclick="{destroy(user.id)}" title="{t(\'verbs.delete\')}"><i class="fa fa-trash"></i></a> </td> </tr> </tbody> </table> <div class="hr"></div> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> </div>', "", "", function(opts) {
    var fetch, queryUpdate, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.page);
    tag.on("before-mount", function() {
        if (!tag.isAdmin()) {
            return wApp.bus.trigger("access-denied");
        }
    });
    tag.on("mount", function() {
        tag.title(tag.t("activerecord.models.user", {
            count: "other"
        }));
        fetch();
        return tag.on("routing:query", fetch);
    });
    tag.on("unmount", function() {
        return tag.off("routing:query", fetch);
    });
    fetch = function(newOpts) {
        return Zepto.ajax({
            url: "/users",
            data: {
                include: "security,technical",
                terms: tag.opts.query.search,
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
        return wApp.bus.trigger("query-update", newQuery);
    };
});

riot.tag2("kor-welcome", '<div class="kor-content-box"> <h1>{config().welcome_title}</h1> <div class="target"></div> <div class="teaser" if="{currentUser() && !isGuest()}"> <span>{tcap(\'pages.random_entities\')}</span> <div class="hr"></div> <kor-gallery-grid entities="{entities()}"></kor-gallery-grid> </div> </div>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.config);
    tag.mixin(wApp.mixins.page);
    tag.on("mount", function() {
        Zepto(tag.root).find(".target").html(tag.config().welcome_html);
        return Zepto.ajax({
            url: "/entities",
            data: {
                include: "gallery_data",
                sort: "random",
                per_page: 4
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

riot.tag2("kor-pagination", '<virtual if="{isActive()}"> <button onclick="{inputChanged}"> {t(\'goto\', {interpolations: {where: \'\'}})} </button> <span>{t(\'nouns.page\')}</span> <a title="{t(\'previous\')}" show="{!isFirst()}" onclick="{toPrevious}" href="#"><i class="fa fa-arrow-left"></i></a> <kor-input riot-value="{currentPage()}" onchange="{inputChanged}" name="page" ref="manual" type="{\'number\'}"></kor-input> {t(\'of\', {interpolations: {amount: totalPages()}})} <a title="{t(\'next\')}" show="{!isLast()}" onclick="{toNext}" href="#"><i class="fa fa-arrow-right"></i></a> </virtual> <virtual if="{opts.perPageControl}"> <img src="images/vertical_dots.gif"> <kor-input type="select" options="{perPageOptions()}" riot-value="{opts.perPage}" onchange="{selectChanged}" ref="select"></kor-input> {t(\'results_per_page\')} </virtual>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.config);
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
            if (Zepto.isFunction(tag.opts.onPaginate)) {
                return tag.opts.onPaginate(new_page, tag.opts.perPage);
            } else {
                return wApp.routing.query({
                    page: new_page
                });
            }
        }
    };
    tag.changePerPage = function(new_per_page) {
        if (new_per_page !== tag.opts.perPage) {
            if (Zepto.isFunction(tag.opts.onPaginate)) {
                return tag.opts.onPaginate(1, new_per_page);
            }
        }
    };
    tag.totalPages = function() {
        return Math.ceil(tag.opts.total / tag.opts.perPage);
    };
    tag.perPageOptions = function() {
        var defaults, i, results;
        defaults = [ 5, 10, 20, 50, 100 ];
        results = function() {
            var j, len, results1;
            results1 = [];
            for (j = 0, len = defaults.length; j < len; j++) {
                i = defaults[j];
                if (i < tag.config().max_results_per_request) {
                    results1.push(i);
                }
            }
            return results1;
        }();
        results.push(tag.config().max_results_per_request);
        return results;
    };
    tag.inputChanged = function(event) {
        return tag.to(parseInt(tag.refs.manual.value()));
    };
    tag.selectChanged = function(event) {
        return tag.changePerPage(parseInt(tag.refs.select.value()));
    };
    tag.isActive = function() {
        return tag.opts.total && tag.opts.total > tag.opts.perPage;
    };
});

riot.tag2("kor-properties-editor", '<div class="header"> <button onclick="{add}" class="pull-right"> {t(\'verbs.add\', {capitalize: true})} </button> <label> {t(         \'activerecord.attributes.relationship.property.other\',         {capitalize: true}       )} </label> <div class="clearfix"></div> </div> <ul> <li each="{property, i in properties}"> <kor-input name="value" riot-value="{property.value}" ref="inputs"></kor-input> <div class="kor-text-right"> <button onclick="{remove(i)}"> {t(\'verbs.remove\')} </button> </div> </li> </ul>', "", "", function(opts) {
    var tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.on("mount", function() {
        var i, len, p, ref, results;
        tag.properties = [];
        if (tag.opts.properties) {
            ref = tag.opts.properties;
            results = [];
            for (i = 0, len = ref.length; i < len; i++) {
                p = ref[i];
                results.push(tag.properties.push({
                    value: p
                }));
            }
            return results;
        }
    });
    tag.add = function(event) {
        event.preventDefault();
        tag.properties.push({
            value: ""
        });
        return tag.update();
    };
    tag.remove = function(index) {
        return function(event) {
            event.preventDefault();
            tag.properties.splice(index, 1);
            return tag.update();
        };
    };
    tag.value = function() {
        var e, i, len, ref, results;
        ref = wApp.utils.toArray(tag.refs.inputs);
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
            e = ref[i];
            results.push(e.value());
        }
        return results;
    };
});

riot.tag2("kor-relation", '<div class="name"> <kor-pagination if="{data}" page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" on-paginate="{pageUpdate}"></kor-pagination> {opts.name} <a if="{expandable()}" title="{expanded ? t(\'verbs.collapse\') : t(\'verbs.expand\')}" onclick="{toggle}" class="toggle" href="#"> <i show="{!expanded}" class="fa fa-chevron-up"></i> <i show="{expanded}" class="fa fa-chevron-down"></i> </a> <div class="clearfix"></div> </div> <virtual if="{data}"> <kor-relationship each="{relationship in data.records}" entity="{parent.opts.entity}" relationship="{relationship}"></kor-relationship> </virtual>', "", "", function(opts) {
    var fetch, tag, updateExpansion;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.info);
    tag.on("mount", function() {
        var base;
        (base = tag.opts).query || (base.query = {});
        return fetch();
    });
    tag.reFetch = fetch;
    tag.expandable = function() {
        var i, len, r, ref;
        if (!tag.data) {
            return false;
        }
        ref = tag.data.records;
        for (i = 0, len = ref.length; i < len; i++) {
            r = ref[i];
            if (r.media_relations > 0) {
                return true;
            }
        }
        return false;
    };
    tag.toggle = function(event) {
        event.preventDefault();
        tag.expanded = !tag.expanded;
        return updateExpansion();
    };
    tag.pageUpdate = function(newPage) {
        opts.query.page = newPage;
        return fetch();
    };
    tag.refresh = function() {
        return fetch();
    };
    fetch = function() {
        return Zepto.ajax({
            url: "/relationships",
            data: {
                from_entity_id: tag.opts.entity.id,
                page: tag.opts.query.page,
                relation_name: tag.opts.name,
                except_to_kind_id: tag.info().medium_kind_id,
                include: "all"
            },
            success: function(data) {
                tag.data = data;
                tag.update();
                return updateExpansion();
            }
        });
    };
    updateExpansion = function() {
        var i, len, r, ref, results;
        if (tag.expanded !== void 0) {
            ref = tag.tags["kor-relationship"];
            results = [];
            for (i = 0, len = ref.length; i < len; i++) {
                r = ref[i];
                results.push(r.trigger("toggle", tag.expanded));
            }
            return results;
        }
    };
});

riot.tag2("kor-relation-merger", '{t(\'messages.relation_merger_prompt\')} <ul if="{ids(true).length > 0}"> <li each="{relation, id in relations}"> <a href="#" onclick="{setAsTarget}">{relation.name} / {relation.reverse_name}</a> ({relation.id}) <i if="{relation.id == target}" class="fa fa-star"></i> <a title="{t(\'verbs.remove\')}" href="#" onclick="{removeRelation}"><i class="fa fa-times"></i></a> </li> </ul> <div class="kor-text-right" if="{valid()}"> <button onclick="{check}">{t(\'verbs.check\')}</button> <button onclick="{merge}">{t(\'verbs.merge\')}</button> </div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
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
        if (window.confirm(tag.t("confirm.long_time_warning"))) {
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

riot.tag2("kor-relation-selector", '<kor-input if="{relationNames && relationNames.length > 0}" name="relation_name" label="{tcap(\'activerecord.models.relation\')}" type="select" placeholder="{t(\'nothing_selected\')}" options="{relationNames}" riot-value="{opts.riotValue}" errors="{opts.errors}" ref="input" onchange="{onchange}"></kor-input> <em if="{relationNames && relationNames.length == 0}" class="error">{t(\'messages.no_relations_provided\')}</em>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.on("mount", function() {
        tag.trigger("reload");
    });
    tag.on("reload", function() {
        fetch();
    });
    tag.onchange = function(event) {
        event.stopPropagation();
        var h = tag.opts.onchange;
        if (h) {
            h();
        }
    };
    tag.value = function() {
        var i = tag.refs.input;
        return i ? i.value() : null;
    };
    var fetch = function() {
        Zepto.ajax({
            url: "/relations/names",
            data: {
                from_kind_ids: tag.opts.sourceKindId,
                to_kind_ids: tag.opts.targetKindId
            },
            success: function(data) {
                tag.relationNames = data;
                tag.update();
            }
        });
    };
});

riot.tag2("kor-relationship", '<div class="part"> <virtual if="{!editorActive}"> <div class="kor-layout-commands"> <virtual if="{allowedToEdit()}"> <kor-clipboard-control entity="{to()}" if="{to().medium_id}"></kor-clipboard-control> <a href="#" onclick="{edit}" title="{t(\'objects.edit\', {interpolations: {o: \'activerecord.models.relationship\'}})}"><i class="fa fa-pencil"></i></a> <a href="#" onclick="{delete}" title="{t(\'objects.delete\', {interpolations: {o: \'activerecord.models.relationship\'}})}"><i class="fa fa-trash"></i></a> </virtual> </div> <kor-entity no-clipboard="{true}" entity="{relationship.to}"></kor-entity> <a if="{relationship.media_relations > 0}" title="{expanded ? t(\'verbs.collapse\') : t(\'verbs.expand\')}" onclick="{toggle}" class="toggle" href="#"> <i show="{!expanded}" class="fa fa-chevron-up"></i> <i show="{expanded}" class="fa fa-chevron-down"></i> </a> <virtual if="{relationship.properties.length > 0}"> <hr> <div each="{property in relationship.properties}">{property}</div> </virtual> <virtual if="{relationship.datings.length > 0}"> <hr> <div each="{dating in relationship.datings}"> {dating.label}: <strong>{dating.dating_string}</strong> </div> </virtual> <div class="clearfix"></div> <virtual if="{expanded && data}"> <kor-pagination page="{opts.query.page}" per-page="{data.per_page}" total="{data.total}" page-update-handler="{pageUpdate}"></kor-pagination> <div class="clearfix"></div> </virtual> </virtual> </div> <table class="media-relations" if="{expanded && data && !editorActive}"> <tbody> <tr each="{row in wApp.utils.inGroupsOf(3, data.records, null)}"> <td each="{relationship in row}"> <virtual if="{relationship}"> <div class="kor-text-right"> <kor-clipboard-control entity="{relationship.to}"></kor-clipboard-control> </div> <a href="#/entities/{relationship.to.id}"> <img class="medium" riot-src="{relationship.to.medium.url.thumbnail}"> </a> </virtual> </td> </tr> </tbody> </table>', "", "", function(opts) {
    var fetchPage, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.info);
    tag.on("mount", function() {
        var base;
        tag.relationship = tag.opts.relationship;
        return (base = tag.opts).query || (base.query = {});
    });
    tag.to = function() {
        return tag.relationship.to;
    };
    tag.toggle = function(event) {
        event.preventDefault();
        return tag.trigger("toggle");
    };
    tag.on("toggle", function(value) {
        tag.expanded = value === void 0 ? !tag.expanded : value;
        if (tag.expanded && !tag.data) {
            fetchPage();
        }
        return tag.update();
    });
    tag.allowedToEdit = function() {
        return tag.allowedTo("edit", tag.opts.entity.collection_id) || tag.allowedTo("edit", tag.to().collection_id);
    };
    tag.edit = function(event) {
        event.preventDefault();
        return wApp.bus.trigger("modal", "kor-relationship-editor", {
            directedRelationship: tag.relationship
        });
    };
    tag["delete"] = function(event) {
        event.preventDefault();
        if (confirm(tag.t("confirm.sure"))) {
            return Zepto.ajax({
                type: "DELETE",
                url: "/relationships/" + tag.relationship.relationship_id,
                success: function(data) {
                    return wApp.bus.trigger("relationship-deleted");
                }
            });
        }
    };
    tag.pageUpdate = function(newPage) {
        tag.opts.query.page = newPage;
        return fetchPage();
    };
    fetchPage = function() {
        return Zepto.ajax({
            url: "/relationships",
            data: {
                page: tag.opts.query.page,
                per_page: 9,
                relation_name: tag.opts.name,
                to_kind_id: tag.info().medium_kind_id,
                from_entity_id: tag.to().id,
                include: "to,properties,datings"
            },
            success: function(data) {
                tag.data = data;
                return tag.update();
            }
        });
    };
});

riot.tag2("kor-relationship-editor", '<div class="kor-content-box" if="{relationship}"> <h1 if="{relationship.id}"> {tcap(\'objects.edit\', {interpolations: {o: \'activerecord.models.relationship\'}})} </h1> <h1 if="{!relationship.id}"> {tcap(\'objects.create\', {interpolations: {o: \'activerecord.models.relationship\'}})} </h1> <form onsubmit="{save}" onreset="{cancel}" if="{relationship}"> <kor-input name="lock_version" riot-value="{relationship.lock_version || 0}" ref="fields" type="hidden"></kor-input> <kor-relation-selector source-kind-id="{sourceKindId}" target-kind-id="{targetKindId}" riot-value="{relationship.relation_name}" errors="{errors.relation_id}" ref="relationName" onchange="{relationChanged}"></kor-relation-selector> <hr> <kor-entity-selector relation-name="{relationship.relation_name}" riot-value="{relationship.to_id}" errors="{errors.to_id}" ref="targetId" onchange="{targetChanged}"></kor-entity-selector> <hr> <kor-properties-editor properties="{relationship.properties}" ref="properties"></kor-properties-editor> <hr> <kor-datings-editor riot-value="{relationship.datings}" ref="datings" errors="{errors.datings}" for="relationship" default-dating-label="{config().relationship_dating_label}"></kor-datings-editor> <hr> <kor-input type="submit"></kor-input> <kor-input type="reset" label="{tcap(\'cancel\')}"></kor-input> </form> </div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.config);
    tag.mixin(wApp.mixins.editor);
    tag.resource = {
        singular: "relationship",
        plural: "relationships"
    };
    tag.resourceId = function() {
        return tag.relationship.relationship_id;
    };
    tag.on("mount", function() {
        tag.relationship = tag.opts.directedRelationship;
        tag.errors = {};
        if (tag.relationship.from_id) {
            fetchSource();
        }
        if (tag.relationship.to_id) {
            fetchTarget();
        }
    });
    tag.cancel = function() {
        tag.opts.modal.trigger("close");
    };
    tag.relationChanged = function() {
        tag.relationship.relation_name = tag.refs.relationName.value();
        tag.update();
        tag.refs.targetId.trigger("reload");
    };
    tag.targetChanged = function() {
        tag.relationship.to_id = tag.refs.targetId.value();
        fetchTarget();
    };
    tag.onSuccess = function() {
        tag.errors = {};
        tag.update();
        if (tag.relationship.id) {
            wApp.bus.trigger("relationship-updated");
        } else {
            wApp.bus.trigger("relationship-created");
        }
        tag.opts.modal.trigger("close");
    };
    tag.formValues = function() {
        return {
            from_id: tag.relationship.from_id,
            relation_name: tag.refs.relationName.value(),
            to_id: tag.refs.targetId.value(),
            properties: tag.refs.properties.value(),
            datings_attributes: tag.refs.datings.value()
        };
    };
    var fetchSource = function() {
        Zepto.ajax({
            url: "/entities/" + tag.relationship.from_id,
            success: function(data) {
                tag.sourceKindId = data.kind_id;
                tag.update();
                tag.refs.relationName.trigger("reload");
            }
        });
    };
    var fetchTarget = function() {
        if (tag.relationship.to_id) {
            Zepto.ajax({
                url: "/entities/" + tag.relationship.to_id,
                success: function(data) {
                    tag.targetKindId = data.kind_id;
                    tag.update();
                    tag.refs.relationName.trigger("reload");
                }
            });
        } else {
            tag.targetKindId = null;
            tag.update();
            tag.refs.relationName.trigger("reload");
        }
    };
});

riot.tag2("kor-search-result", '<a href="#/entities/{opts.entity.id}" class="to-entity"> <kor-clipboard-control entity="{opts.entity}"></kor-clipboard-control> <div class="labels"> <virtual if="{!opts.entity.medium_id}"> <div class="name">{opts.entity.display_name}</div> <div class="kind">{opts.entity.kind_name}</div> </virtual> <virtual if="{opts.entity.medium_id}"> <img riot-src="{opts.entity.medium.url.icon}"> </virtual> </div> <div class="media" if="{opts.entity.related.length > 0}"> <kor-entity each="{rel in opts.entity.related}" entity="{rel.to}" no-content-type="{true}"></kor-entity> <div class="clearfix"></div> </div> </a>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
});

riot.tag2("kor-sort-by", '<a href="#" onclick="{click}"><yield></yield>{directionIndicator()}</a>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.click = function(event) {
        event.preventDefault();
        var newQuery = {};
        if (currentPage()) {
            newQuery["page"] = 1;
        }
        if (currentSort() != tag.opts.key) {
            newQuery["sort"] = tag.opts.key;
            newQuery["direction"] = "asc";
        } else {
            if (currentDirection() == "asc") {
                newQuery["direction"] = "desc";
            } else {
                newQuery["direction"] = "asc";
            }
        }
        wApp.routing.query(newQuery);
    };
    tag.directionIndicator = function() {
        if (currentSort() == tag.opts.key) {
            if (currentDirection() == "asc") {
                return " ▴";
            } else {
                return " ▾";
            }
        } else {
            return "";
        }
    };
    var currentSort = function() {
        return wApp.routing.query()["sort"];
    };
    var currentDirection = function() {
        return wApp.routing.query()["direction"];
    };
    var currentPage = function() {
        return wApp.routing.query()["page"];
    };
});

riot.tag2("kor-sa-entity", '<div class="auth" if="{!authorized}"> <strong>Info</strong> <p> It seems you are not allowed to see this content. Please <a href="{login_url()}">login</a> to the kor installation first. </p> </div> <a href="{url()}" if="{authorized}" target="_blank"> <img if="{data.medium}" riot-src="{image_url()}"> <div if="{!data.medium}"> <h3>{data.display_name}</h3> <em if="{include(\'kind\')}"> {data.kind_name} <span show="{data.subtype}">({data.subtype})</span> </em> </div> </a>', "", "class=\"{'kor-style': opts.korStyle, 'kor': opts.korStyle}\"", function(opts) {
    var tag;
    tag = this;
    tag.authorized = true;
    tag.on("mount", function() {
        var base;
        if (tag.opts.id) {
            base = $("script[kor-url]").attr("kor-url") || "";
            return Zepto.ajax({
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

riot.tag2("kor-synonyms-editor", '<kor-input label="{opts.label}" type="textarea" ref="field"></kor-input>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.on("mount", function() {
        tag.set(tag.opts.riotValue);
    });
    tag.name = function() {
        return tag.opts.name;
    };
    tag.set = function(value) {
        if (value) {
            tag.refs["field"].set(value.join("\n"));
        }
    };
    tag.value = function() {
        var text = tag.tags["kor-input"].value();
        if (text.match(/^\s*$/)) {
            return [];
        }
        var lines = text.split("\n");
        return lines.filter(function(e) {
            return !!e;
        });
    };
});

riot.tag2("kor-user-selector", '<kor-input label="{label()}" name="{opts.name}" placeholder="{t(\'prompts.autocomplete\')}" ref="input"></kor-input>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.on("mount", function() {
        input().on("keydown", function(event) {
            var newValue = tag.refs.input.value();
            if (newValue != tag.old_field_value) {
                tag.old_field_value = newValue;
                tag.user_id = null;
                tag.update();
            }
        });
    });
    tag.on("update", function() {});
    tag.on("updated", function() {
        input().tinyAutocomplete({
            method: "get",
            url: "/users",
            queryProperty: "terms",
            grouped: false,
            itemTemplate: '<li class="autocomplete-item">{{full_name}}</li>',
            onSelect: function(el, val) {
                tag.user_id = val.id;
                tag.refs.input.set(val.display_name);
                tag.old_field_value = val.display_name;
                Zepto(tag.root).trigger("change");
            }
        });
        tag.autocomplete = input().tinyAutocomplete();
    });
    tag.label = function() {
        if (tag.user_id) {
            return tag.opts.label + " ✔";
        } else {
            return tag.opts.label;
        }
    };
    tag.name = function() {
        return tag.refs.input.name();
    };
    tag.value = function() {
        return tag.user_id;
    };
    tag.set = function(user_id) {
        tag.user_id = user_id;
        fetch();
    };
    var input = function() {
        return Zepto(tag.refs.input.root).find("input");
    };
    var fetch = function() {
        Zepto.ajax({
            url: "/users/" + tag.user_id,
            success: function(data) {
                tag.refs.input.set(data.display_name);
                tag.old_field_value = data.display_name;
            },
            error: function(xhr) {
                tag.refs.input.set("");
                xhr.noMessaging = true;
            }
        });
    };
});

riot.tag2("w-app", '<kor-header></kor-header> <div> <kor-menu></kor-menu> <div class="w-content"></div> <kor-footer></kor-footer> </div> <w-modal ref="modal"></w-modal> <w-messaging></w-messaging>', "", "", function(opts) {
    var accessDenied, goBack, pageTitleHandler, queryUpdate, redirectTo, serverCodeHandler, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.auth);
    window.kor = tag;
    tag.on("mount", function() {
        wApp.bus.on("routing:path", tag.routeHandler);
        wApp.bus.on("routing:query", tag.queryHandler);
        wApp.bus.on("page-title", pageTitleHandler);
        wApp.bus.on("access-denied", accessDenied);
        wApp.bus.on("go-back", goBack);
        wApp.bus.on("query-update", queryUpdate);
        wApp.bus.on("server-code", serverCodeHandler);
        if (tag.opts.routing) {
            return wApp.routing.setup();
        }
    });
    tag.on("unmount", function() {
        wApp.bus.off("page-title", pageTitleHandler);
        wApp.bus.off("routing:query", tag.queryHandler);
        wApp.bus.off("routing:path", tag.routeHandler);
        wApp.bus.off("access-denied", accessDenied);
        wApp.bus.off("go-back", goBack);
        wApp.bus.off("query-update", queryUpdate);
        wApp.bus.off("server-code", serverCodeHandler);
        if (tag.opts.routing) {
            return wApp.routing.tearDown();
        }
    });
    pageTitleHandler = function(newTitle) {
        var nv;
        nv = newTitle ? newTitle : "ConedaKOR";
        return Zepto("head title").html(nv);
    };
    accessDenied = function() {
        return tag.mountTag("kor-access-denied");
    };
    serverCodeHandler = function(code) {
        if (code === "terms-not-accepted") {
            return redirectTo("/legal");
        }
    };
    goBack = function() {
        return wApp.routing.back();
    };
    queryUpdate = function(newQuery) {
        return wApp.routing.query(newQuery);
    };
    tag.routeHandler = function(parts) {
        var m, opts, path, tagName;
        tagName = "kor-loading";
        opts = {
            query: parts["hash_query"]
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

              case "/statistics":
                return "kor-statistics";

              case "/legal":
                return "kor-legal";

              case "/about":
                return "kor-about";

              default:
                if (tag.currentUser()) {
                    if (!tag.isGuest() && !tag.currentUser().terms_accepted && path !== "/legal") {
                        return redirectTo("/legal");
                    } else {
                        if (m = path.match(/^\/users\/([0-9]+)\/edit$/)) {
                            opts["id"] = parseInt(m[1]);
                            return "kor-user-editor";
                        } else if (m = path.match(/^\/entities\/([0-9]+)$/)) {
                            opts["id"] = parseInt(m[1]);
                            return "kor-entity-page";
                        } else if (m = path.match(/^\/kinds\/([0-9]+)\/edit\/fields\/new$/)) {
                            opts["id"] = parseInt(m[1]);
                            opts["newField"] = true;
                            return "kor-kind-editor";
                        } else if (m = path.match(/^\/kinds\/([0-9]+)\/edit\/fields\/([0-9]+)\/edit$/)) {
                            opts["id"] = parseInt(m[1]);
                            opts["fieldId"] = parseInt(m[2]);
                            return "kor-kind-editor";
                        } else if (m = path.match(/^\/kinds\/([0-9]+)\/edit\/generators\/new$/)) {
                            opts["id"] = parseInt(m[1]);
                            opts["newGenerator"] = true;
                            return "kor-kind-editor";
                        } else if (m = path.match(/^\/kinds\/([0-9]+)\/edit\/generators\/([0-9]+)\/edit$/)) {
                            opts["id"] = parseInt(m[1]);
                            opts["generatorId"] = parseInt(m[2]);
                            return "kor-kind-editor";
                        } else if (m = path.match(/^\/kinds\/([0-9]+)\/edit$/)) {
                            opts["id"] = parseInt(m[1]);
                            return "kor-kind-editor";
                        } else if (m = path.match(/^\/entities\/new$/)) {
                            opts["kindId"] = parts["hash_query"]["kind_id"];
                            return "kor-entity-editor";
                        } else if (m = path.match(/^\/entities\/([0-9]+)\/edit$/)) {
                            opts["id"] = parseInt(m[1]);
                            return "kor-entity-editor";
                        } else if (m = path.match(/^\/credentials\/([0-9]+)\/edit$/)) {
                            opts["id"] = parseInt(m[1]);
                            return "kor-credential-editor";
                        } else if (m = path.match(/^\/collections\/([0-9]+)\/edit$/)) {
                            opts["id"] = parseInt(m[1]);
                            return "kor-collection-editor";
                        } else if (m = path.match(/^\/groups\/categories(?:\/([0-9]+))?\/new$/)) {
                            opts["parentId"] = parseInt(m[1]);
                            return "kor-admin-group-category-editor";
                        } else if (m = path.match(/^\/groups\/categories\/([0-9]+)\/edit$/)) {
                            opts["id"] = parseInt(m[1]);
                            return "kor-admin-group-category-editor";
                        } else if (m = path.match(/^\/groups\/categories(?:\/([0-9]+))?$/)) {
                            if (m[1]) {
                                opts["parentId"] = parseInt(m[1]);
                            }
                            return "kor-admin-group-categories";
                        } else if (m = path.match(/^\/groups\/categories(?:\/([0-9]+))?\/admin\/([0-9]+)\/edit$/)) {
                            opts["categoryId"] = parseInt(m[1]);
                            opts["id"] = parseInt(m[2]);
                            return "kor-admin-group-editor";
                        } else if (m = path.match(/^\/groups\/categories(?:\/([0-9]+))?\/admin\/new$/)) {
                            opts["categoryId"] = parseInt(m[1]);
                            return "kor-admin-group-editor";
                        } else if (m = path.match(/^\/groups\/admin\/([0-9]+)$/)) {
                            opts["id"] = parseInt(m[1]);
                            opts["type"] = "authority";
                            return "kor-entity-group";
                        } else if (m = path.match(/^\/groups\/user\/([0-9]+)\/edit$/)) {
                            opts["id"] = parseInt(m[1]);
                            return "kor-user-group-editor";
                        } else if (m = path.match(/^\/groups\/user\/([0-9]+)$/)) {
                            opts["id"] = parseInt(m[1]);
                            opts["type"] = "user";
                            return "kor-entity-group";
                        } else if (m = path.match(/^\/relations\/([0-9]+)\/edit$/)) {
                            opts["id"] = parseInt(m[1]);
                            return "kor-relation-editor";
                        } else if (m = path.match(/^\/media\/([0-9]+)$/)) {
                            opts["id"] = parseInt(m[1]);
                            return "kor-medium-page";
                        } else if (m = path.match(/^\/pub\/([0-9]+)\/([0-9a-f]+)$/)) {
                            opts["userId"] = parseInt(m[1]);
                            opts["uuid"] = m[2];
                            return "kor-publishment";
                        } else {
                            switch (path) {
                              case "/clipboard":
                                return "kor-clipboard";

                              case "/profile":
                                return "kor-profile";

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

                              case "/search":
                                return "kor-search";

                              case "/kinds":
                                return "kor-kinds";

                              case "/kinds/new":
                                return "kor-kind-editor";

                              case "/credentials":
                                return "kor-credentials";

                              case "/credentials/new":
                                return "kor-credential-editor";

                              case "/collections":
                                return "kor-collections";

                              case "/collections/new":
                                return "kor-collection-editor";

                              case "/upload":
                                return "kor-upload";

                              case "/groups/user/new":
                                return "kor-user-group-editor";

                              case "/groups/user":
                                return "kor-user-groups";

                              case "/groups/shared":
                                opts["type"] = "shared";
                                return "kor-user-groups";

                              case "/relations/new":
                                return "kor-relation-editor";

                              case "/relations":
                                return "kor-relations";

                              case "/settings":
                                return "kor-settings-editor";

                              case "/password-recovery":
                                return "kor-password-recovery";

                              case "/groups/published":
                                return "kor-publishments";

                              case "/groups/published/new":
                                return "kor-publishment-editor";

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
        tag.closeModal();
        return tag.mountTagAndAnimate(tagName, opts);
    };
    tag.queryHandler = function(parts) {
        if (tag.mountedTag) {
            tag.mountedTag.opts.query = parts["hash_query"];
            return tag.mountedTag.trigger("routing:query");
        }
    };
    tag.closeModal = function() {
        return tag.refs.modal.trigger("close");
    };
    tag.mountTagAndAnimate = function(tagName, opts) {
        var element, mountIt;
        if (opts == null) {
            opts = {};
        }
        if (tagName) {
            element = Zepto(tag.root).find(".w-content");
            mountIt = function() {
                wApp.bus.trigger("page-title");
                tag.mountedTag = riot.mount(element[0], tagName, opts)[0];
                if (wApp.info.data.env !== "test") {
                    element.animate({
                        opacity: 1
                    }, 200);
                }
                return wApp.utils.scrollToTop();
            };
            if (tag.mountedTag) {
                if (wApp.info.data.env !== "test") {
                    return element.animate({
                        opacity: 0
                    }, 200, function() {
                        tag.mountedTag.unmount(true);
                        return mountIt();
                    });
                } else {
                    tag.mountedTag.unmount(true);
                    return mountIt();
                }
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

riot.tag2("w-app-loader", '<div class="app" ref="target"> <div class="kor-loading-screen"> <img src="/images/loading.gif"><br> <strong>… loading …</strong> </div> </div>', "", "", function(opts) {
    var tag = this;
    var reloadApp = function() {
        console.log("reloading app");
        unmount();
        var preloaders = wApp.setup();
        $.when.apply(null, preloaders).then(function() {
            mountApp();
        });
    };
    var unmount = function() {
        if (tag.mountedApp) {
            tag.mountedApp.unmount(true);
        }
    };
    var mountApp = function() {
        updateLayout();
        var opts = {
            routing: true
        };
        tag.mountedApp = riot.mount(tag.refs.target, "w-app", opts)[0];
        console.log("ConedaKOR frontend loaded");
    };
    var updateLayout = function() {
        var meta = Zepto("meta[http-equiv=content-language]");
        var locale = wApp.session.current.locale;
        meta.attr("content", locale);
        var m = Zepto("<meta>").attr("name", "description").attr("content", wApp.i18n.t(locale, "meta.description"));
        meta.after(m);
        m = Zepto("<meta>").attr("name", "author").attr("content", wApp.i18n.t(locale, "meta.author"));
        meta.after(m);
        m = Zepto("<meta>").attr("name", "description").attr("keywords", wApp.i18n.t(locale, "meta.keywords"));
        meta.after(m);
        var url = wApp.info.data.custom_css;
        if (url) {
            var link = Zepto('<link rel="stylesheet" href="' + url + '">');
            link[0].onload = showBody;
            Zepto("head").append(link);
        } else {
            showBody();
        }
    };
    var showBody = function() {
        Zepto("body").show();
    };
    tag.on("mount", function() {
        wApp.bus.on("reload-app", reloadApp);
        wApp.bus.trigger("reload-app");
    });
    tag.on("unmount", function() {
        wApp.bus.off("reload-app", reloadApp);
    });
});

riot.tag2("kor-header", '<a href="#/" class="logo"> <kor-logo></kor-logo> </a> <div class="session"> <kor-loading></kor-loading> <span> <strong>ConedaKOR</strong> {t(\'nouns.version\')} {info().version} </span> <span if="{currentUser()}"> <img src="images/vertical_dots.gif"> {t(\'logged_in_as\')}: <strong>{currentUser().display_name}</strong> <a href="#/profile" title="{tcap(\'edit_self\')}"><i class="fa fa-wrench"></i></a> <span if="{!isGuest()}"> <img src="images/vertical_dots.gif"> <kor-logout></kor-logout> </span> </span> </div> <div class="clearfix"></div>', "", "", function(opts) {
    var tag = this;
    tag.mixin(wApp.mixins.info);
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
});

riot.tag2("kor-menu", '<ul if="{currentUser()}"> <li if="{!isLoggedIn()}"> <a href="#/login">{tcap(\'nouns.login\')}</a> </li> <li> <a href="#/search">{tcap(\'nouns.search\')}</a> </li> </ul> <ul> <li if="{isLoggedIn()}"> <a href="#/clipboard">{tcap(\'nouns.clipboard\')}</a> </li> <li if="{currentUser()}"> <a href="#/new-media">{tcap(\'pages.new_media\')}</a> </li> </ul> <div class="header">{tcap(\'nouns.group\', {count: \'other\'})}</div> <ul> <li> <a href="#/groups/categories"> {tcap(\'activerecord.models.authority_group.other\')} </a> </li> <li if="{isLoggedIn()}"> <a href="#/groups/user"> {tcap(\'activerecord.models.user_group.other\')} </a> </li> <li if="{isLoggedIn()}"> <a href="#/groups/shared"> {tcap(\'activerecord.attributes.user_group.shared\', {count: \'other\'})} </a> </li> <li if="{isLoggedIn()}"> <a href="#/groups/published"> {tcap(\'activerecord.attributes.user_group.published\', {count: \'other\'})} </a> </li> </ul> <virtual if="{isLoggedIn() && (allowedTo(\'create\'))}"> <div class="header">{tcap(\'verbs.create\')}</div> <ul> <li> <kor-input if="{kinds && kinds.records.length > 0}" name="new_entity_type" type="select" onchange="{newEntity}" options="{kinds.records}" placeholder="{tcap(\'objects.new\', {interpolations: {o: \'activerecord.models.entity.one\'}})}" ref="kind_id"></kor-input> </li> <li if="{isLoggedIn()}"> <a href="#/upload">{tcap(\'verbs.upload\')}</a> </li> <li> <a href="#/relations"> {tcap(\'activerecord.models.relation.other\')} </a> </li> <li> <a href="#/kinds"> {tcap(\'activerecord.models.kind.other\')} </a> </li> </ul> </virtual> <virtual if="{isLoggedIn() && (allowedTo(\'delete\') || allowedTo(\'edit\'))}"> <div class="header">{tcap(\'verbs.edit\')}</div> <ul> <li if="{allowedTo(\'delete\')}"> <a href="#/entities/invalid">{tcap(\'nouns.invalid_entity\', {count: \'other\'})}</a> </li> <li if="{allowedTo(\'edit\')}"> <a href="#/entities/recent">{tcap(\'nouns.new_entity\', {count: \'other\'})}</a> </li> <li if="{allowedTo(\'edit\')}"> <a href="#/entities/isolated">{tcap(\'nouns.isolated_entity\', {count: \'other\'})}</a> </li> </ul> </virtual> <div if="{isAdmin()}" class="header">{tcap(\'nouns.administration\')}</div> <ul if="{isAdmin()}"> <li> <a href="#/settings"> {tcap(\'activerecord.models.setting\', {count: \'other\'})} </a> </li> <li> <a href="#/collections"> {tcap(\'activerecord.models.collection.other\')} </a> </li> <li> <a href="#/credentials"> {tcap(\'activerecord.models.credential.other\')} </a> </li> <li> <a href="#/users"> {tcap(\'activerecord.models.user.other\')} </a> </li> </ul> <ul> <li if="{hasHelp()}"> <a href="#/help" onclick="{showHelp}">{tcap(\'nouns.help\')}</a> </li> <li> <a href="#/statistics">{tcap(\'nouns.statistics\')}</a> </li> <li if="{hasLegal()}"> <a href="#/legal">{tcap(\'legal\')}</a> </li> <li> <a href="#/about">{tcap(\'about\')}</a> </li> <li> <a href="https://coneda.net" target="_blank">coneda.net</a> </li> </ul> <ul> <li if="{hasAnyRole()}"> <a href="https://github.com/coneda/kor/issues"> {tcap(\'report_a_problem\')} </a> </li> <li hide="{hasAnyRole()}"> <a href="mailto:{config().maintainer_mail}"> {tcap(\'report_a_problem\')} </a> </li> </ul>', "", "", function(opts) {
    var fetchKinds, tag;
    tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);
    tag.mixin(wApp.mixins.config);
    tag.on("mount", function() {
        wApp.bus.on("reload-kinds", fetchKinds);
        return fetchKinds();
    });
    tag.on("umount", function() {
        return wApp.bus.off("reload-kinds", fetchKinds);
    });
    tag.showHelp = function(event) {
        event.preventDefault();
        return wApp.config.showHelp("general");
    };
    tag.hasHelp = function() {
        return wApp.config.hasHelp("general");
    };
    tag.hasLegal = function() {
        return !!wApp.info.data.legal_html;
    };
    tag.newEntity = function(event) {
        var kind_id;
        event.preventDefault();
        kind_id = tag.refs.kind_id.value();
        wApp.routing.path("/entities/new?kind_id=" + kind_id);
        return tag.refs.kind_id.set(0);
    };
    fetchKinds = function() {
        return $.ajax({
            url: "/kinds",
            data: {
                no_media: true
            },
            success: function(data) {
                tag.kinds = data;
                return tag.update();
            }
        });
    };
});

riot.tag2("w-messaging", '<div each="{message in messages}" class="message {\'error\': error(message), \'notice\': notice(message)}"> <i show="{notice(message)}" class="fa fa-warning"></i> <i show="{error(message)}" class="fa fa-info-circle"></i> {message.content} </div>', "", "", function(opts) {
    var ajaxCompleteHandler, duration, self;
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
        window.setTimeout(self.drop, duration());
        return self.update();
    });
    duration = function() {
        return 3e3;
    };
    ajaxCompleteHandler = function(event, request, options) {
        var contentType, data, e, type;
        contentType = request.getResponseHeader("content-type");
        if (contentType && contentType.match(/^application\/json/) && request.response) {
            try {
                data = JSON.parse(request.response);
                if (data.message && !request.noMessaging) {
                    type = request.status >= 200 && request.status < 300 ? "notice" : "error";
                    wApp.bus.trigger("message", type, data.message);
                }
                if (data.notice && !request.noMessaging) {
                    wApp.bus.trigger("message", "notice", data.notice);
                }
                if (data.code) {
                    return wApp.bus.trigger("server-code", data.code);
                }
            } catch (error) {
                e = error;
                return console.log(e, request);
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
        opts.modal = tag;
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