#include<netinet/in.h>
#include<errno.h>
#include<netdb.h>
#include<stdio.h> //For standard things
#include<stdlib.h>    //malloc
#include<string.h>    //strlen
 
#include<netinet/ip_icmp.h>   //Provides declarations for icmp header
#include<netinet/udp.h>   //Provides declarations for udp header
#include<netinet/tcp.h>   //Provides declarations for tcp header
#include<netinet/ip.h>    //Provides declarations for ip header
#include<netinet/if_ether.h>  //For ETH_P_ALL
#include<net/ethernet.h>  //For ether_header
#include<sys/socket.h>
#include<arpa/inet.h>
#include<sys/ioctl.h>
#include<sys/time.h>
#include<sys/types.h>
#include<unistd.h>

#include "maze.c"
 
bool ProcessPacket(unsigned char* , int);
void process_udp_packet(unsigned char * , int );
void PrintData (unsigned char* , int);
 
FILE *logfile;
struct sockaddr_in source,dest;
//int tcp=0,udp=0,icmp=0,others=0,igmp=0,total=0,i,j; 

union zzz
{
	struct sockaddr addr;
	unsigned char chars[16];
};

void print_zzz(struct sockaddr addr)
{
	union zzz xxx;
	xxx.addr = addr;
	int i;
	for (i = 0; i < 16; ++i)
		printf("%02X", xxx.chars[i]);
	printf(" !\n");
}

int main()
{
	init();

    int saddr_size , data_size;
    struct sockaddr saddr;
         
    unsigned char *buffer = (unsigned char *) malloc(65536); //Its Big!
     
    logfile=fopen("log.txt","w");
    if(logfile==NULL) 
    {
        printf("Unable to create log.txt file.");
    }
    printf("Starting...\n");
     
    int sock_raw = socket( AF_PACKET , SOCK_RAW, htons(ETH_P_ALL)) ;
    //setsockopt(sock_raw , SOL_SOCKET , SO_BINDTODEVICE , "eth0" , strlen("eth0")+ 1 );
     
    if(sock_raw < 0)
    {
        //Print the error with proper message
        perror("Socket Error");
        return 1;
    }
    while(1)
    {
        saddr_size = sizeof saddr;
        //Receive a packet
        data_size = recvfrom(sock_raw , buffer , 65536 , 0 , &saddr , (socklen_t*)&saddr_size);
        if(data_size < 0)
        {
            printf("Recvfrom error , failed to get packets\n");
            return 1;
        }
		if (data_size > 0)
		{
        	//Now process the packet
        	//sleep(1);
			if (ProcessPacket(buffer , data_size))
			{
				//fprintf(stderr, "Received %d bytes\n", data_size);
		
				//print_zzz(saddr);

			}
		}
	}
    close(sock_raw);
    printf("Finished");
    return 0;
}
 
bool ProcessPacket(unsigned char* buffer, int size)
{
    //Get the IP Header part of this packet , excluding the ethernet header
    struct iphdr *iph = (struct iphdr*)(buffer + sizeof(struct ethhdr));
    switch (iph->protocol) //Check the Protocol and do accordingly...
    {
        case 17: //UDP Protocol
            process_udp_packet(buffer , size);
            return true;
			break;
         
        default: //Some Other Protocol like ARP, TCP, IGMP etc.
            break;
    }
	return false;
}
 
 
void process_udp_packet(unsigned char *Buffer , int Size)
{
     
    unsigned short iphdrlen;
     
    struct iphdr *iph = (struct iphdr *)(Buffer +  sizeof(struct ethhdr));
    iphdrlen = iph->ihl*4;
     
    struct udphdr *udph = (struct udphdr*)(Buffer + iphdrlen  + sizeof(struct ethhdr));
     
    int header_size =  sizeof(struct ethhdr) + iphdrlen + sizeof udph;
     
	unsigned short source_port = ntohs(udph->source);
	unsigned short destination_port = ntohs(udph->dest);
	size_t len = ntohs(udph->len);
	char* payload = Buffer + header_size;
	size_t payload_len = Size - header_size;
	payload[payload_len] = 0;	

	fprintf(stderr, "Payload len: %d\n", (int) payload_len);
	fprintf(stderr, "Payload: %s\n", payload);

	if (! isRequestValid(destination_port, payload))
	{
		fprintf(stderr, "Non-valid request\n");
	}
	else
	{
		char* result = GetAnswer(destination_port, payload);
		fprintf(stderr, "%s\n", result);
		
		int sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
		int on = 1;
		setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(int));

		struct sockaddr_in daddr;
		memset((char*) &daddr, 0, sizeof(daddr));
		daddr.sin_family = AF_INET;
		daddr.sin_port = htons(destination_port);
		daddr.sin_addr = *(struct in_addr*) &(iph->daddr);
		if (bind(sock, (struct sockaddr*)&daddr, sizeof(daddr)) < 0)
			fprintf(stderr, "Error calling bind: %d\n", errno);
		else
		{		
			struct sockaddr_in saddr;
			memset((char *) &saddr, 0, sizeof(saddr));
	    	saddr.sin_family = AF_INET;
    		saddr.sin_port = htons(source_port);
    		saddr.sin_addr = *(struct in_addr*) &(iph->saddr);
	
			fprintf(stderr, "Sent %d bytes to client\n", (int) sendto(sock, result, strlen(result), 0, (struct sockaddr*) &saddr, sizeof(saddr)));
			close(sock);
		}	
		free(result);
	}


/*
    print_ip_header(Buffer,Size);           
     
    fprintf(logfile , "\nUDP Header\n");
    fprintf(logfile , "   |-Source Port      : %d\n" , ntohs(udph->source));
    fprintf(logfile , "   |-Destination Port : %d\n" , ntohs(udph->dest));
    fprintf(logfile , "   |-UDP Length       : %d\n" , ntohs(udph->len));
    fprintf(logfile , "   |-UDP Checksum     : %d\n" , ntohs(udph->check));
     
    fprintf(logfile , "\n");
    fprintf(logfile , "IP Header\n");
    PrintData(Buffer , iphdrlen);
         
    fprintf(logfile , "UDP Header\n");
    PrintData(Buffer+iphdrlen , sizeof udph);
         
    fprintf(logfile , "Data Payload\n");    
     
    //Move the pointer ahead and reduce the size of string
    PrintData(Buffer + header_size , Size - header_size);
      
    fprintf(logfile , "\n###########################################################");
	*/
}
 
 
void PrintData (unsigned char* data , int Size)
{
    int i , j;
    for(i=0 ; i < Size ; i++)
    {
        if( i!=0 && i%16==0)   //if one line of hex printing is complete...
        {
            fprintf(logfile , "         ");
            for(j=i-16 ; j<i ; j++)
            {
                if(data[j]>=32 && data[j]<=128)
                    fprintf(logfile , "%c",(unsigned char)data[j]); //if its a number or alphabet
                 
                else fprintf(logfile , "."); //otherwise print a dot
            }
            fprintf(logfile , "\n");
        } 
         
        if(i%16==0) fprintf(logfile , "   ");
            fprintf(logfile , " %02X",(unsigned int)data[i]);
                 
        if( i==Size-1)  //print the last spaces
        {
            for(j=0;j<15-i%16;j++) 
            {
              fprintf(logfile , "   "); //extra spaces
            }
             
            fprintf(logfile , "         ");
             
            for(j=i-i%16 ; j<=i ; j++)
            {
                if(data[j]>=32 && data[j]<=128) 
                {
                  fprintf(logfile , "%c",(unsigned char)data[j]);
                }
                else
                {
                  fprintf(logfile , ".");
                }
            }
             
            fprintf(logfile ,  "\n" );
        }
    }
}
