var commonjsGlobal = typeof globalThis !== 'undefined' ? globalThis : typeof window !== 'undefined' ? window : typeof global !== 'undefined' ? global : typeof self !== 'undefined' ? self : {};

var base64$1 = {exports: {}};

/*! https://mths.be/base64 v1.0.0 by @mathias | MIT license */
var base64 = base64$1.exports;

var hasRequiredBase64;

function requireBase64 () {
	if (hasRequiredBase64) return base64$1.exports;
	hasRequiredBase64 = 1;
	(function (module, exports) {
(function(root) {

			// Detect free variables `exports`.
			var freeExports = exports;

			// Detect free variable `module`.
			var freeModule = module &&
				module.exports == freeExports && module;

			// Detect free variable `global`, from Node.js or Browserified code, and use
			// it as `root`.
			var freeGlobal = typeof commonjsGlobal == 'object' && commonjsGlobal;
			if (freeGlobal.global === freeGlobal || freeGlobal.window === freeGlobal) {
				root = freeGlobal;
			}

			/*--------------------------------------------------------------------------*/

			var InvalidCharacterError = function(message) {
				this.message = message;
			};
			InvalidCharacterError.prototype = new Error;
			InvalidCharacterError.prototype.name = 'InvalidCharacterError';

			var error = function(message) {
				// Note: the error messages used throughout this file match those used by
				// the native `atob`/`btoa` implementation in Chromium.
				throw new InvalidCharacterError(message);
			};

			var TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
			// http://whatwg.org/html/common-microsyntaxes.html#space-character
			var REGEX_SPACE_CHARACTERS = /[\t\n\f\r ]/g;

			// `decode` is designed to be fully compatible with `atob` as described in the
			// HTML Standard. http://whatwg.org/html/webappapis.html#dom-windowbase64-atob
			// The optimized base64-decoding algorithm used is based on @atk’s excellent
			// implementation. https://gist.github.com/atk/1020396
			var decode = function(input) {
				input = String(input)
					.replace(REGEX_SPACE_CHARACTERS, '');
				var length = input.length;
				if (length % 4 == 0) {
					input = input.replace(/==?$/, '');
					length = input.length;
				}
				if (
					length % 4 == 1 ||
					// http://whatwg.org/C#alphanumeric-ascii-characters
					/[^+a-zA-Z0-9/]/.test(input)
				) {
					error(
						'Invalid character: the string to be decoded is not correctly encoded.'
					);
				}
				var bitCounter = 0;
				var bitStorage;
				var buffer;
				var output = '';
				var position = -1;
				while (++position < length) {
					buffer = TABLE.indexOf(input.charAt(position));
					bitStorage = bitCounter % 4 ? bitStorage * 64 + buffer : buffer;
					// Unless this is the first of a group of 4 characters…
					if (bitCounter++ % 4) {
						// …convert the first 8 bits to a single ASCII character.
						output += String.fromCharCode(
							0xFF & bitStorage >> (-2 * bitCounter & 6)
						);
					}
				}
				return output;
			};

			// `encode` is designed to be fully compatible with `btoa` as described in the
			// HTML Standard: http://whatwg.org/html/webappapis.html#dom-windowbase64-btoa
			var encode = function(input) {
				input = String(input);
				if (/[^\0-\xFF]/.test(input)) {
					// Note: no need to special-case astral symbols here, as surrogates are
					// matched, and the input is supposed to only contain ASCII anyway.
					error(
						'The string to be encoded contains characters outside of the ' +
						'Latin1 range.'
					);
				}
				var padding = input.length % 3;
				var output = '';
				var position = -1;
				var a;
				var b;
				var c;
				var buffer;
				// Make sure any padding is handled outside of the loop.
				var length = input.length - padding;

				while (++position < length) {
					// Read three bytes, i.e. 24 bits.
					a = input.charCodeAt(position) << 16;
					b = input.charCodeAt(++position) << 8;
					c = input.charCodeAt(++position);
					buffer = a + b + c;
					// Turn the 24 bits into four chunks of 6 bits each, and append the
					// matching character for each of them to the output.
					output += (
						TABLE.charAt(buffer >> 18 & 0x3F) +
						TABLE.charAt(buffer >> 12 & 0x3F) +
						TABLE.charAt(buffer >> 6 & 0x3F) +
						TABLE.charAt(buffer & 0x3F)
					);
				}

				if (padding == 2) {
					a = input.charCodeAt(position) << 8;
					b = input.charCodeAt(++position);
					buffer = a + b;
					output += (
						TABLE.charAt(buffer >> 10) +
						TABLE.charAt((buffer >> 4) & 0x3F) +
						TABLE.charAt((buffer << 2) & 0x3F) +
						'='
					);
				} else if (padding == 1) {
					buffer = input.charCodeAt(position);
					output += (
						TABLE.charAt(buffer >> 2) +
						TABLE.charAt((buffer << 4) & 0x3F) +
						'=='
					);
				}

				return output;
			};

			var base64 = {
				'encode': encode,
				'decode': decode,
				'version': '1.0.0'
			};

			// Some AMD build optimizers, like r.js, check for specific condition patterns
			// like the following:
			if (freeExports && !freeExports.nodeType) {
				if (freeModule) { // in Node.js or RingoJS v0.8.0+
					freeModule.exports = base64;
				} else { // in Narwhal or RingoJS v0.7.0-
					for (var key in base64) {
						base64.hasOwnProperty(key) && (freeExports[key] = base64[key]);
					}
				}
			} else { // in Rhino or a web browser
				root.base64 = base64;
			}

		}(base64)); 
	} (base64$1, base64$1.exports));
	return base64$1.exports;
}

requireBase64();

var utf8 = {};

/*! https://mths.be/utf8js v3.0.0 by @mathias */

var hasRequiredUtf8;

function requireUtf8 () {
	if (hasRequiredUtf8) return utf8;
	hasRequiredUtf8 = 1;
	(function (exports) {
(function(root) {

			var stringFromCharCode = String.fromCharCode;

			// Taken from https://mths.be/punycode
			function ucs2decode(string) {
				var output = [];
				var counter = 0;
				var length = string.length;
				var value;
				var extra;
				while (counter < length) {
					value = string.charCodeAt(counter++);
					if (value >= 0xD800 && value <= 0xDBFF && counter < length) {
						// high surrogate, and there is a next character
						extra = string.charCodeAt(counter++);
						if ((extra & 0xFC00) == 0xDC00) { // low surrogate
							output.push(((value & 0x3FF) << 10) + (extra & 0x3FF) + 0x10000);
						} else {
							// unmatched surrogate; only append this code unit, in case the next
							// code unit is the high surrogate of a surrogate pair
							output.push(value);
							counter--;
						}
					} else {
						output.push(value);
					}
				}
				return output;
			}

			// Taken from https://mths.be/punycode
			function ucs2encode(array) {
				var length = array.length;
				var index = -1;
				var value;
				var output = '';
				while (++index < length) {
					value = array[index];
					if (value > 0xFFFF) {
						value -= 0x10000;
						output += stringFromCharCode(value >>> 10 & 0x3FF | 0xD800);
						value = 0xDC00 | value & 0x3FF;
					}
					output += stringFromCharCode(value);
				}
				return output;
			}

			function checkScalarValue(codePoint) {
				if (codePoint >= 0xD800 && codePoint <= 0xDFFF) {
					throw Error(
						'Lone surrogate U+' + codePoint.toString(16).toUpperCase() +
						' is not a scalar value'
					);
				}
			}
			/*--------------------------------------------------------------------------*/

			function createByte(codePoint, shift) {
				return stringFromCharCode(((codePoint >> shift) & 0x3F) | 0x80);
			}

			function encodeCodePoint(codePoint) {
				if ((codePoint & 0xFFFFFF80) == 0) { // 1-byte sequence
					return stringFromCharCode(codePoint);
				}
				var symbol = '';
				if ((codePoint & 0xFFFFF800) == 0) { // 2-byte sequence
					symbol = stringFromCharCode(((codePoint >> 6) & 0x1F) | 0xC0);
				}
				else if ((codePoint & 0xFFFF0000) == 0) { // 3-byte sequence
					checkScalarValue(codePoint);
					symbol = stringFromCharCode(((codePoint >> 12) & 0x0F) | 0xE0);
					symbol += createByte(codePoint, 6);
				}
				else if ((codePoint & 0xFFE00000) == 0) { // 4-byte sequence
					symbol = stringFromCharCode(((codePoint >> 18) & 0x07) | 0xF0);
					symbol += createByte(codePoint, 12);
					symbol += createByte(codePoint, 6);
				}
				symbol += stringFromCharCode((codePoint & 0x3F) | 0x80);
				return symbol;
			}

			function utf8encode(string) {
				var codePoints = ucs2decode(string);
				var length = codePoints.length;
				var index = -1;
				var codePoint;
				var byteString = '';
				while (++index < length) {
					codePoint = codePoints[index];
					byteString += encodeCodePoint(codePoint);
				}
				return byteString;
			}

			/*--------------------------------------------------------------------------*/

			function readContinuationByte() {
				if (byteIndex >= byteCount) {
					throw Error('Invalid byte index');
				}

				var continuationByte = byteArray[byteIndex] & 0xFF;
				byteIndex++;

				if ((continuationByte & 0xC0) == 0x80) {
					return continuationByte & 0x3F;
				}

				// If we end up here, it’s not a continuation byte
				throw Error('Invalid continuation byte');
			}

			function decodeSymbol() {
				var byte1;
				var byte2;
				var byte3;
				var byte4;
				var codePoint;

				if (byteIndex > byteCount) {
					throw Error('Invalid byte index');
				}

				if (byteIndex == byteCount) {
					return false;
				}

				// Read first byte
				byte1 = byteArray[byteIndex] & 0xFF;
				byteIndex++;

				// 1-byte sequence (no continuation bytes)
				if ((byte1 & 0x80) == 0) {
					return byte1;
				}

				// 2-byte sequence
				if ((byte1 & 0xE0) == 0xC0) {
					byte2 = readContinuationByte();
					codePoint = ((byte1 & 0x1F) << 6) | byte2;
					if (codePoint >= 0x80) {
						return codePoint;
					} else {
						throw Error('Invalid continuation byte');
					}
				}

				// 3-byte sequence (may include unpaired surrogates)
				if ((byte1 & 0xF0) == 0xE0) {
					byte2 = readContinuationByte();
					byte3 = readContinuationByte();
					codePoint = ((byte1 & 0x0F) << 12) | (byte2 << 6) | byte3;
					if (codePoint >= 0x0800) {
						checkScalarValue(codePoint);
						return codePoint;
					} else {
						throw Error('Invalid continuation byte');
					}
				}

				// 4-byte sequence
				if ((byte1 & 0xF8) == 0xF0) {
					byte2 = readContinuationByte();
					byte3 = readContinuationByte();
					byte4 = readContinuationByte();
					codePoint = ((byte1 & 0x07) << 0x12) | (byte2 << 0x0C) |
						(byte3 << 0x06) | byte4;
					if (codePoint >= 0x010000 && codePoint <= 0x10FFFF) {
						return codePoint;
					}
				}

				throw Error('Invalid UTF-8 detected');
			}

			var byteArray;
			var byteCount;
			var byteIndex;
			function utf8decode(byteString) {
				byteArray = ucs2decode(byteString);
				byteCount = byteArray.length;
				byteIndex = 0;
				var codePoints = [];
				var tmp;
				while ((tmp = decodeSymbol()) !== false) {
					codePoints.push(tmp);
				}
				return ucs2encode(codePoints);
			}

			/*--------------------------------------------------------------------------*/

			root.version = '3.0.0';
			root.encode = utf8encode;
			root.decode = utf8decode;

		}(exports)); 
	} (utf8));
	return utf8;
}

requireUtf8();

class AppEvent extends Event {
  constructor(typeArg, data = null) {
    super(typeArg);
    this.data = data;
  }
}

class Bus extends EventTarget {
  constructor() {
    super();

    this.data = {};
  }

  on(event, handler) {
    this.addEventListener(event, handler);
  }

  off(event, handler) {
    this.removeEventListener(event, handler);
  }

  emit(name, data) {
    const event = new AppEvent(name, data);
    this.dispatchEvent(event);
  }
}

new Bus();

class Database {
  constructor() {
    this.queue = [];
    this.ready = false;

    this.actions = {};

    this.handler = this.handler.bind(this);
    this.loaded = this.loaded.bind(this);
  }

  action(name, implementation) {
    this.actions[name] = implementation;
  }

  handler(event) {
    const name = event.data.action;

    if (name != 'init') {
      if (!this.ready) {
        this.queue.push(event);
        return
      }
    }

    const messageId = event.data.messageId;
    const now = new Date();

    const implementation = this.actions[name];
    if (!implementation) {
      postMessage({action: 'unknown-action', payload: event.data});
      return
    }

    console.log(`'${name}' request:`, event.data);

    const result = implementation(event.data);

    const respond = (results) => {
      postMessage({
        messageId: messageId,
        action: `${name}-results`,
        ...results
      });

      console.log(`'${name}' response (${new Date() - now} ms): `, results);
    };

    result instanceof Promise ?
      result.then(results => respond(results)) :
      respond(result);
  }

  loaded() {
    console.log(`database loaded`);

    this.ready = true;
    for (const job of this.queue) {
      this.handler(job);
    }
    this.queue = [];
  }
}

class I18n {
  constructor() {
    this.locale = 'en';
    this.translations = null;
    this.fallbacks = [];

    this.fetch = this.fetch.bind(this);
    this.setLocale = this.setLocale.bind(this);
    this.setFallbacks = this.setFallbacks.bind(this);
    this.translate = this.translate.bind(this);
    this.localize = this.localize.bind(this);
    this.translatedCounter = this.translatedCounter.bind(this);
  }

  fetch(url) {
    return fetch(url).
      then(r => r.json()).
      then(data => this.translations = data)
  }

  setLocale(newLocale) {
    this.locale = newLocale;
  }

  setFallbacks(fallbacks) {
    this.fallbacks = fallbacks;
  }

  lookup(key) {
    const sets = (
      Array.isArray(this.translations) ?
      this.translations :
      [this.translations]
    );

    for (const set of sets) {
      const candidate = set[this.locale][key];
      if (candidate) {return candidate}
    }
  }

  translate(key, opts = {}) {
    if (!this.translations) {
      return "TRANSLATIONS NOT LOADED"
    }

    try {
      let result = this.lookup(key);

      for (const [k, v] of Object.entries(opts)) {
        const regex = new RegExp(`\\%\\{${k}\\}`, 'g');
        result = result.replaceAll(regex, v);
      }

      if (!result) {
        console.warn(`not found: ${this.locale}:${key}`);
        return key
      }

      return result
    } catch(e) {
      console.warn(e);
      return `not found: '${this.locale}:${key}'`
    }
  }

  translatedCounter(amount, singular, plural) {
    if (amount == 1) {
      return `${amount} ${this.translate(singular)}`
    } else {
      return `${amount} ${this.translate(plural)}`
    }
  }

  localize(object) {
    if (typeof object == 'object') {
      const json = JSON.stringify(object);
      const locales = [this.locale, ...this.fallbacks];
      for (const l of locales) {
        const result = object[l];
        if (result) {
          return result
        }
      }

      return `NO TRANSLATION FOR locale ${this.locale} for ${json}`
    }

    return object
  }
}

new I18n();

const config = {
  setup: function () {
    return Zepto.ajax({
      url: '/settings',
      success: function (data) {
        wApp.config.data = data;
      }
    })
  },
  refresh: function () {
    wApp.config.setup().then(function () {
      riot.update();
    });
  },
  hasHelp: function (key) {
    return wApp.config.helpFor(key).length > 0
  },
  helpFor: function (key) {
    var locale = wApp.session.current.locale;
    var help = wApp.config.data.values['help_' + key + '.' + locale];
    return help ? help.trim() : ""
  },
  showHelp: function (k) {
    wApp.bus.trigger('modal', 'kor-help', {key: k});
  },
  env: {
    ROOT_URL: "http://localhost:3000"
  }
};

if (typeof wApp !== 'undefined') {
  wApp.config = config;

  wApp.mixins.config = {
    config: function () {
      return wApp.config.data.values
    }
  };

  wApp.bus.on('config-updated', wApp.config.refresh);
}

let database = new Database();
onmessage = database.handler;

const promises = [];

// promises.push(
//   fetch(`${config.env.ROOT_URL}/settings`).then(r => r.json()).then(data => {
//     console.log(data)
//     storage['records'] = data
//   })
// )

Promise.all(promises).then(data => {
  console.log('ALL loaded');
  database.loaded();
});


// actions

database.action('live-legacy', data => {
  const {opts} = data;
});
//# sourceMappingURL=db.js.map
