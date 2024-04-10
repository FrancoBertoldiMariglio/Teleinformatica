from mininet.net import Mininet
from mininet.node import Node
from mininet.log import setLogLevel, info
from mininet.cli import CLI


def myNetwork():
    net = Mininet()

    info('*** Adding controller\n')
    net.addController(name='c0')

    info('*** Adding hosts\n')
    h1 = net.addHost('h1', ip='10.0.1.2/24', defaultRoute='via 10.0.1.1')
    h2 = net.addHost('h2', ip='10.0.2.2/24', defaultRoute='via 10.0.2.1')

    info('*** Adding router\n')
    r1 = net.addHost('r1', ip='192.168.100.1/29')
    r2 = net.addHost('r2', ip='192.168.100.9/29')
    r3 = net.addHost('r3', ip='192.168.100.17/29')

    info('*** Creating links\n')
    net.addLink(h1, r1)
    net.addLink(h2, r2)
    net.addLink(r1, r3)
    net.addLink(r2, r3)

    info('*** Starting network\n')
    net.start()

    info('*** Configuring hosts\n')
    r1.cmd('ifconfig r1-eth1 10.0.1.1/24')
    r2.cmd('ifconfig r2-eth1 10.0.2.1/24')

    info('*** Running CLI\n')
    CLI(net)

    info('*** Stopping network')
    net.stop()


if __name__ == '__main__':
    setLogLevel('info')
    myNetwork()