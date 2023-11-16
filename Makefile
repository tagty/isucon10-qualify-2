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
	ssh isucon10-qualify-1 "sudo systemctl restart isuumo.go.service"

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
		./bench --target-url http://172.31.35.16:80"

pt-query-digest:
	ssh isucon10-qualify-1 "sudo pt-query-digest --limit 10 /var/log/mysql/mysql-slow.log"

ALPSORT=sum
# /api/estate/req_doc/16750
# /api/estate/7356
# /api/chair/11230
# /api/chair/buy/13729
# /api/recommended_estate/9162
# /api/chair/search?page=3&perPage=25&widthRangeId=0
# /api/estate/search?doorWidthRangeId=1&page=4&perPage=25
ALPM=/api/estate/req_doc/[0-9]+,/api/estate/[0-9]+,/api/chair/[0-9]+,/api/chair/buy/[0-9]+,/api/recommended_estate/[0-9]+,/api/chair/search?.+,/api/estate/search?.+
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