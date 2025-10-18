all: build up

# Build images
build:
	docker-compose -f srcs/docker-compose.yml build
	# -f especifica el path del compose file

# Start containers in detached mode
up:
	docker-compose -f srcs/docker-compose.yml up -d

# Stop containers only
down:
	docker-compose -f srcs/docker-compose.yml down

# Stop containers + remove volumes
down-volumes:
	docker-compose -f srcs/docker-compose.yml down -v

# Stop containers, remove volumes, and remove images
clean: down-volumes
	docker-compose -f srcs/docker-compose.yml rm -f
	docker rmi -f $(shell docker images 'inception-*' -q) 2>/dev/null || true

# Remove host files for volumes (use with caution!)
clean-host-files:
	sudo rm -rf /home/martalc/data/wordpress/*
	sudo rm -rf /home/martalc/data/database/*

# stop containers, volumes, images + host files
deep-clean: clean clean-host-files

# Rebuild and restart all services
rebuild: deep-clean build up

# Show logs for all services (follow mode)
logs:
	docker-compose -f srcs/docker-compose.yml logs -f

# Help target
help:
	@echo "Makefile targets:"
	@echo "  all           : build and start containers"
	@echo "  build         : build images"
	@echo "  up            : start containers in detached mode"
	@echo "  down          : stop containers"
	@echo "  down-volumes  : stop containers + remove volumes"
	@echo "  clean         : stop containers, remove volumes & images"
	@echo "  deep-clean    : stop containers, remove volumes & images + rm host files"
	@echo "  rebuild       : deep-clean, build and start containers"
	@echo "  logs          : show live logs of all services"

.PHONY: all build up down down-volumes clean clean-host-files deep-clean rebuild logs help
