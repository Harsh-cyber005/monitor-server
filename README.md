### Monitoring Server

This is the repository for the Monitor server which is used to expose routes for the Monitor project. This was my first try to build a monitoring system like Prometheus and Grafana, even though I do not know how do they work. This project was built to just monitor my Virtual Machines over the cloud for several purposes. One of the purpose being able to make another project which deploys react and node.js applications on my VMs in a click.

#### Tech-Stack used:

- Node
- Typescript
- Sqlite
- pnpm (as the package manager)
- prisma (as the ORM)

#### Steps to start this Project on your machine

1. clone the repo into your machine
    ```bash
    git clone https://github.com/Harsh-cyber005/monitor-server.git
    ```

2. ensure you have Node installed in your machine
    ```bash
    node -v
    ```
    This project was built on __Node v24.12.0__

3. ensure you have pnpm installed in your machine
    ```bash
    npm install pnpm -g
    ```

4. move into the project directory
    ```bash
    cd monitor-server/
    ```

5. install dependencies
    ```bash
    pnpm install
    ```

6. you may need to approve several engines like prisma-engine, etc. approve all of them using:
    ```bash
    pnpm approve-builds
    ```

7. now make a .env file using the .env.example file as reference, by default it has all the non-secret values set

8. now migrate the prisma schema into the new dev.db database using:
    ```bash
    pnpm exec prisma migrate deploy
    ```

9. generate the prisma client
    ```bash
    pnpm exec prisma generate
    ```

10. (Optional) you can view your database live at [PORT-51212](http://localhost:51212/), if you do:
    ```bash
    pnpm exec prisma studio
    ```


#### Track your VM

1. Send a post request to the route `/vm/create` with body:
    ```json
    {
        "vmName": "your-vm-name",
    }
    ```

2. You will get a response like this:
    ```json
    {
        "setupLink": "your-setup-link",
        "command": "curl -fsSL your-setup-link | bash"
    }
    ```

3. Copy the command and run it on your VM where you want to track metrics from. This will download and run the setup script on your VM.

This sets up the VM to send metrics data to the central Monitor server.