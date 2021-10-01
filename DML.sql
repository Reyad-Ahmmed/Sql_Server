use houseservicedb
go
--Initail data
insert into workareas (skill) values
('Plumbing'),('Pipe fitting'),('Electircal works'),('Pest control'),('Mice control')
go
--Test insert worker proc
exec spInsertWorker 'Asgar Ali', --name
					'01710XXXXXX', --phone
					750.00, --payrate
					'1, 2' --work skill --Plumbing, Pipe fitting

exec spInsertWorker 'Sumon Mia', --name
					'01710XXXXXX', --phone
					700.00, --payrate
					'1, 2' --work skill --Plumbing, Pipe fitting
exec spInsertWorker 'Ayub Ali', --name
					'01710XXXXXX', --phone
					900.00, --payrate
					'3' --work skill - electrical work
exec spInsertWorker 'Masum Ahmed', --name
					'01710XXXXXX', --phone
					950.00, --payrate
					'3' --work skill - electrical work
exec spInsertWorker 'Iman Ali', --name
					'01710XXXXXX', --phone
					900.00, --payrate
					'3' --work skill - electrical work
exec spInsertWorker 'Abdul Jabber', --name
					'01710XXXXXX', --phone
					300.00, --payrate
					'4,5' --work skill --pest+mice control
exec spInsertWorker 'Jalal Hossain', --name
					'01710XXXXXX', --phone
					300.00, --payrate
					'4,5' --work skill --pest+mice control
exec spInsertWorker 'Alal Hossain', --name
					'01710XXXXXX', --phone
					300.00, --payrate
					'4' --work skill --pest control
go
select * from workers
select * from workerareas
go
--test work create proc
exec spCreateWork	'Rahmatullah Muzahid', --customer name
					'12, Gulshan-1', --address
					'Swage pipe replacement ', --description
					3, --plubming work,
					'2020-12-01', --start date
					'1,2' --workers set for the work
exec spCreateWork	'Abul Kashem', --customer name
					'45, Mirpur-13', --address
					'Garage electric wiring', --description
					3, --electrical work,
					'2020-12-01', --start date
					'3,4' --workers set for the work
go
select * from works
select * from workerpayments
go
--test complete work
exec spSetWorkComplete @workid =1, @end ='2020-12-04 12:00'
go
select * from works where workid=1
select * from workerpayments where workid=1
go
exec spSetWorkComplete @workid =2, @end ='2020-12-01'
go
select * from works where workid=2
select * from workerpayments where workid=2
go
--test function
select * from fnWorkerList(1)
go
