# Default target
all: build up


# Build all images
build:
	docker-compose -f srcs/docker-compose.yml build
	# -f especifica el path del compose file

# Start all containers in detached mode
up:
	docker-compose -f srcs/docker-compose.yml up -d

# Stop containers without removing volumes or images
down:
	docker-compose -f srcs/docker-compose.yml down

# Stop containers and remove volumes (persistent data)
down-volumes:
	docker-compose -f srcs/docker-compose.yml down -v

# Stop containers, remove volumes, and remove images
clean: down-volumes
	docker-compose -f srcs/docker-compose.yml rm -f
	docker image prune -f

# Show logs for all services (follow mode)
logs:
	docker-compose -f srcs/docker-compose.yml logs -f

# Rebuild and restart all services
rebuild: clean build up

# Remove host files for volumes (use with caution!)
clean-host-files:
	sudo rm -rf /home/martalc/data/wordpress/*
	sudo rm -rf /home/martalc/data/database/*

deep-clean: clean clean-host-files


# Help target
help:
	@echo "Makefile targets:"
	@echo "  all           : build and start containers"
	@echo "  build         : build Docker images"
	@echo "  up            : start containers in detached mode"
	@echo "  down          : stop containers"
	@echo "  down-volumes  : stop containers and remove volumes"
	@echo "  clean         : stop containers, remove volumes and images"
	@echo "  rebuild       : clean, build and start containers"
	@echo "  logs          : show live logs of all services"

.PHONY: all build up down down-volumes clean rebuild logs help
