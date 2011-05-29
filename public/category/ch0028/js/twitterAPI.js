/*
 * Copyright (c) 2009 Otchy
 * This source file is subject to the MIT license.
 * http://www.otchy.net
 */
var TwitterAPI = {
	version: '0.9.2',
	doc: document,
	base: 'http://twitter.com/',
	func: null,
	element: null,
	stack: [],
	check: function() {
		if (this.script) {
			alert("Sorry, can't execute two or more API's at same time.");
			return false;
		}
		return true;
	},
	get: function(cmd, func, param) {
		if (!this.check()) { return; }
		this.func = func ;
		this.script = this.doc.createElement('script');
		this.script.src = this.base + cmd + '.json?callback=TwitterAPICallback' + (param ? '&' + param : '');
		this.doc.body.appendChild(this.script);
	},
	post: function(cmd, vals) {
		if (!this.check()) { return; }
		var f = this.doc.getElementById('TwiterAPIForm');
		if (!f) {
			f = this.doc.createElement('form');
			f.id = 'TwiterAPIForm';
			f.method = 'POST';
			f.target = 'TwiterAPIFrame';
			f.style.display = 'none';
			var i = this.doc.createElement('iframe');
			i.name = 'TwiterAPIFrame';
			f.appendChild(i);
			this.doc.body.appendChild(f);
			i.contentWindow.name = i.name;
		}
		f.action = this.base + cmd + '.xml';
		var children = f.childNodes;
		var dels = new Array();
		for (var i=0; i<children.length; i++) {
			var c = children[i];
			if (c.tagName.toLowerCase() == 'input') {
				dels.push(c);
			}
		}
		for (var i=0; i<dels.length; i++) { f.removeChild(dels[i]); }
		if (vals) {
			for (var i=0; i<vals.length; i++) { f.appendChild(vals[i]); }
		}
		f.submit();
	},
	hidden: function(name, value) {
		var h = this.doc.createElement('input');
		h.type = 'hidden';
		h.name = name;
		h.value = value;
		return h;
	},
	clear: function() {
		this.func = null;
		this.doc.body.removeChild(this.script);
		this.script = null;
	},
	cmd: function(cate, method, id) {
		return cate + (method && method.length > 0 ? '/' + method : '') + (id ? '/' + id : '');
	},
	statuses: {
		public_timeline: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('statuses', 'public_timeline'), func, param); },
		friends_timeline: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('statuses', 'friends_timeline', id), func, param); },
		user_timeline: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('statuses', 'user_timeline', id), func, param); },
		show: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('statuses', 'show', id), func, param); },
		update: function(status) {
			var vals = new Array(TwitterAPI.hidden('status', status));
			TwitterAPI.post(TwitterAPI.cmd('statuses', 'update'), vals);
		},
		replies: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('statuses', 'replies'), func, param); },
		destroy: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('statuses', 'destroy', id), func); },
		friends: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('statuses', 'friends', id), func, param); },
		followers: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('statuses', 'followers', id), func, param); },
		featured: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('statuses', 'featured'), func); }
	},
	users: {
		show: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('users', 'show', id), func, param); },
		own: function(func) {
			TwitterAPI.statuses.user_timeline(function(result) {
				if (result && result.length && result.length > 0) {
					func(result[0].user);
				}
			}, null, 'count=1');
		}
	},
	direct_messages: {
		show: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('direct_messages'), func, param); },
		sent: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('direct_messages', 'sent'), func, param); },
		create: function(user, text) {
			var vals = new Array(TwitterAPI.hidden('user', user), TwitterAPI.hidden('text', text));
			TwitterAPI.post(TwitterAPI.cmd('direct_messages', 'new'), vals);
		},
		destroy: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('direct_messages', 'destroy', id), func, param); }
	},
	friendships: {
		create: function(func, id, param) { TwitterAPI.post(TwitterAPI.cmd('friendships', 'create', id), func); },
		destroy: function(func, id, param) { TwitterAPI.post(TwitterAPI.cmd('friendships', 'destroy', id), func); },
		exists: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('friendships', 'exists'), func, param); }
	},
	friends: {
		ids: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('friends', 'ids'), func, param); }
	},
	followers: {
		ids: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('followers', 'ids'), func, param); }
	},
	account: {
		verify_credentials: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('account', 'verify_credentials'), func); },
		end_session: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('account', 'end_session'), func); },
		archive: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('account', 'archive'), func, param);},
		update_location: function(location) {
			var vals = new Array(TwitterAPI.hidden('location', location));
			TwitterAPI.post(TwitterAPI.cmd('account', 'update_location'), vals);
		},
		update_delivery_device: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('account', 'update_delivery_device'), func, param); },
		rate_limit_status: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('account', 'rate_limit_status'), func); }
	},
	favorites: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('favorites', '', id), func, param); },
	favourings: {
		create: function(func, id, param) { TwitterAPI.post(TwitterAPI.cmd('favourings', 'create', id), func); },
		destroy: function(func, id, param) { TwitterAPI.post(TwitterAPI.cmd('favourings', 'destroy', id), func); }
	},
	notifications: {
		follow: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('notifications', 'follow', id)); },
		leave: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('notifications', 'leave', id)); }
	},
	blocks: {
		create: function(func, id, param) { TwitterAPI.post(TwitterAPI.cmd('blocks', 'create', id)); },
		destroy: function(func, id, param) { TwitterAPI.post(TwitterAPI.cmd('blocks', 'destroy', id)); }
	},
	help: {
		test: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('help', 'test')); },
		downtime_schedule: function(func, id, param) { TwitterAPI.get(TwitterAPI.cmd('help', 'downtime_schedule')); }
	}
};
function TwitterAPICallback (obj) {
	try {
		if (TwitterAPI.func) {
			TwitterAPI.func(obj);
		}
	} finally {
		TwitterAPI.clear();
	}
}
