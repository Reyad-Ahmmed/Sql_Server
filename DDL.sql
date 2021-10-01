if db_id('houseservicedb') is null
create database houseservicedb
go
use houseservicedb
go
ALTER DATABASE houseservicedb
SET COMPATIBILITY_LEVEL =  130
GO
create table workareas
(
workareaid int identity primary key,
skill nvarchar (40) not null
)
go
create table workers
(
workerid int identity primary key,
workername nvarchar (40) not null,
phone nvarchar (20) not null,
payrate money not null

)
go
create table workerareas 
(
workerid int not null references  workers (workerid),
areaid int not null references workareas  (workareaid),
primary key (workerid, areaid )
)
go
create table works
(
workid int identity primary key,
customename nvarchar (50) not null,
customeraddress nvarchar (150) not null,
workareaid int not null references workareas  (workareaid ),
workdescription nvarchar (100) not null,
startdate date not null,
endtime datetime null
)
go
create table workerpayments
(
workid int not null references works (workid ),
workerid int not null references workers (workerid ),
totalworkhour float null,
totalpayment money null,
primary key (workid, workerid )
)
go
--proc to insert worker

create proc spInsertWorker	@name nvarchar (40),
							@phone nvarchar (20),
							@payrate money,
							@workareaids nvarchar(1000) -- id in csv like  '1,4,3'
as
	--1 insert worker
	insert into workers(workername, phone, payrate)
	values (@name, @phone, @payrate)
	--2 get new identity value
	declare @id int = SCOPE_IDENTITY()
	--3 insert workerareas
	insert into workerareas (workerid, areaid)
	select @id,RTRIM(LTRIM(value)) as value from string_split(@workareaids, ',')
	--done
go

--proc to create work 

create proc spCreateWork	@customename nvarchar (50),
							@customeraddress nvarchar (150),
							@workdescription nvarchar (100),
							@workareaid int,
							@startdate date,
							@workerids nvarchar(200) 
as
	--insert work
	insert into works (customename, customeraddress, workdescription, workareaid, startdate)
	values (@customename, @customeraddress, @workdescription, @workareaid, @startdate)
	--get new workid
	declare @id int = SCOPE_IDENTITY()
	--insert workers payment
	insert into workerpayments (workid, workerid)
	select @id,RTRIM(LTRIM(value)) as value from string_split(@workerids, ',')
	--finished
	return
go

select DATEDIFF(day, cast(getdate() as date), getdate())
select datepart(hour,getdate())
select DATEADD(dd, 10, cast(getdate() as date))

declare @start date = '2020-12-01'
declare @end datetime = getdate()
declare @ddf int
select @ddf = datediff(day, @start, @end)
select @ddf

declare @endwithoutTime datetime
select @endwithoutTime = dateadd(d, datediff(d, 0, @end), 0)
set @endwithoutTime= dateadd(hour, 10,@endwithoutTime)
select @ddf*10 + DATEDIFF(hour,@endwithoutTime, @end) 
go

--proc to complete work

create proc spSetWorkComplete @workid int, @end datetime
as
	--get total work hour : 10h /day + last day hour from 10am
	declare @start date, @ddf int, @endwithoutTime datetime
	select @start = startdate from works where workid = @workid
	select @ddf = datediff(day, @start, @end)
	select @endwithoutTime = dateadd(d, datediff(d, 0, @end), 0)
	set @endwithoutTime= dateadd(hour, 10,@endwithoutTime)
	set @ddf= @ddf*10 + DATEDIFF(hour,@endwithoutTime, @end) 
	if @ddf <= 0 set @ddf=10
	--update work
	update works
	set endtime = @end
	where workid = @workid
	--update payments
	update wp
	set wp.totalworkhour = @ddf, totalpayment=@ddf*w.payrate
	from workerpayments wp
	inner join workers w on wp.workerid = w.workerid
	where wp.workid = @workid
go

--create function to get a work details with worker list

create function fnWorkerList(@workid int) returns table
as
return
(
	select w.workid, w.customename, w.customeraddress, w.startdate, w.endtime, wk.workername
	from works w
	inner join workerpayments wp on wp.workid = w.workid
	inner join workers wk on wp.workerid = wk.workerid
	where w.workid = @workid
)
go
