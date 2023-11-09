deploy:
	ssh isucon10-qualify-1 " \
		cd /home/isucon/isuumo; \
		git checkout .; \
		git fetch; \
		git checkout $(BRANCH); \
		git reset --hard origin/$(BRANCH)"

build:
	ssh isucon10-qualify-1 " \
		cd /home/isucon/isuumo/webapp/go; \
		/home/isucon/local/go/bin/go build -o isuumo"

go-deploy:
	scp ./webapp/go/isuumo isucon10-qualify-1:/home/isucon/webapp/go/

go-deploy-dir:
	scp -r ./webapp/go isucon10-qualify-1:/home/isucon/webapp/

restart:
	ssh isucon10-qualify-1 "sudo systemctl restart isuumo.service"
	ssh isucon10-qualify-2 "sudo systemctl restart isuumo.service"
	ssh isucon10-qualify-3 "sudo systemctl restart isuumo.service"

mysql-deploy:
	ssh isucon10-qualify-1 "sudo dd of=/etc/mysql/mysql.conf.d/mysqld.cnf" < ./etc/mysql/mysql.conf.d/mysqld.cnf

mysql-rotate:
	ssh isucon10-qualify-1 "sudo rm -f /var/log/mysql/mysql-slow.log"

mysql-restart:
	ssh isucon10-qualify-1 "sudo systemctl restart mysql.service"

nginx-deploy:
	ssh isucon10-qualify-1 "sudo dd of=/etc/nginx/nginx.conf" < ./etc/nginx/nginx.conf
	ssh isucon10-qualify-1 "sudo dd of=/etc/nginx/sites-available/isuumo.conf" < ./etc/nginx/sites-available/isuumo.conf

nginx-rotate:
	ssh isucon10-qualify-1 "sudo rm -f /var/log/nginx/access.log"

nginx-reload:
	ssh isucon10-qualify-1 "sudo systemctl reload nginx.service"

nginx-restart:
	ssh isucon10-qualify-1 "sudo systemctl restart nginx.service"

.PHONY: bench
bench:
	ssh isucon10-qualify-bench " \
		cd /home/isucon/isuumo/bench; \
		./bench --target-url http://172.31.35.16:1323"

pt-query-digest:
	ssh isucon10-qualify-1 "sudo pt-query-digest --limit 10 /var/log/mysql/mysql-slow.log"

ALPSORT=sum
# /api/player/competition/[0-9a-z\-]+/ranking
# /api/player/player/[0-9a-z]+
# /api/organizer/competition/[0-9a-z\-]+/finish
# /api/organizer/competition/[0-9a-z\-]+/score
# /api/organizer/player/[0-9a-z\-]+/disqualified
# /api/admin/tenants/billing
ALPM=/api/player/competition/[0-9a-z\-]+/ranking,/api/player/player/[0-9a-z]+,/api/organizer/competition/[0-9a-z\-]+/finish,/api/organizer/competition/[0-9a-z\-]+/score,/api/organizer/player/[0-9a-z\-]+/disqualified,/api/admin/tenants/billing
OUTFORMAT=count,method,uri,min,max,sum,avg,p99

alp:
	ssh isucon10-qualify-1 "sudo alp ltsv --file=/var/log/nginx/access.log --nosave-pos --pos /tmp/alp.pos --sort $(ALPSORT) --reverse -o $(OUTFORMAT) -m $(ALPM) -q"

.PHONY: pprof
pprof:
	ssh isucon10-qualify-1 " \
		/usr/bin/go tool pprof -seconds=75 /home/isucon/webapp/go/isuumo http://localhost:6060/debug/pprof/profile"

pprof-show:
	$(eval latest := $(shell ssh isucon10-qualify-1 "ls -rt ~/pprof/ | tail -n 1"))
	scp isucon10-qualify-1:~/pprof/$(latest) ./pprof
	go tool pprof -http=":1080" ./pprof/$(latest)

pprof-kill:
	ssh isucon10-qualify-1 "pgrep -f 'pprof' | xargs kill;"