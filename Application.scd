(t=
Task {
	2.do {
		d.fork;
		2.wait;
	};
	3.wait;
	a.fork;
	b.fork;
	c.fork;
	d.fork;
	5.wait;
	d.fork;
	5.wait;
	b.fork;
	c.fork;
	d.fork;
};
)

t.play;


​




s.quit;
s.boot;