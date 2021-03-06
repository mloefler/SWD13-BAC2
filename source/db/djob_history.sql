USE [djob_swd13]
GO

/****** Object:  Table [djob].[DJob]    Script Date: 16.09.2016 19:04:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [djob_history](
	[id] [uniqueidentifier] NOT NULL,
	[version] [binary](8) NOT NULL,
	[tsLastUpdate] [datetime] NOT NULL,
	[update_action] [char](1) NOT NULL,
	[client_name] [varchar](128) NOT NULL,
	[name] [varchar](64) NOT NULL,
	[action] [varchar](128) NOT NULL,
	[state] [varchar](32) NOT NULL,
	[parameter] [nvarchar](max) NULL,
	[intervall] [int] NOT NULL,
	[autoReset] [bit] NOT NULL,
	[tsNextExecution] [datetime] NULL,
	[tsLockAcquired] [datetime] NULL,
	[owner] [varchar](128) NULL,
	[tsLastExecution] [datetime] NULL,
	[createdBy] [varchar](64) NULL,
	[tsCreated] [datetime] NULL,
	[tsModified] [datetime] NULL,
	[avgRuntime] [float] NOT NULL,
	[avgRuntimeLast] [float] NOT NULL,
	[lastRuntime] [float] NULL,
	[expectedRuntime] [float] NULL,
	[job_version] [int] NOT NULL,
 CONSTRAINT [PK_DJob] PRIMARY KEY CLUSTERED 
(
	[id] ASC, 
	[version] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [djob_history] ADD  CONSTRAINT [DF_DJob_state]  DEFAULT ('Inactive') FOR [state]
GO

ALTER TABLE [djob_history]  WITH CHECK ADD  CONSTRAINT [FK_DJob_DJobStates] FOREIGN KEY([state])
REFERENCES [djob].[DJobStates] ([token])
GO

ALTER TABLE [djob].[djob_history] CHECK CONSTRAINT [FK_DJob_DJobStates]
GO

ALTER TABLE [djob].[DJob]  WITH CHECK ADD  CONSTRAINT [FK_DJob_Worker] FOREIGN KEY([owner])
REFERENCES [djob].[Worker] ([name])
GO

ALTER TABLE [djob].[DJob] CHECK CONSTRAINT [FK_DJob_Worker]
GO

CREATE TRIGGER TRIG_DJOB_HISTORY_INSERT ON djob.djob
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @update_time DATETIME;
	SET @update_time = CURRENT_TIMESTAMP;

	DECLARE @event_type char(1)
	IF EXISTS(SELECT * FROM inserted)
	  IF EXISTS(SELECT * FROM deleted)
		SELECT @event_type = 'U'
	ELSE
		SELECT @event_type = 'I'
	ELSE
	  IF EXISTS(SELECT * FROM deleted)
		SELECT @event_type = 'D'
	  ELSE
		--no rows affected - cannot determine event
		SELECT @event_type = '?'

	DECLARE @vers binary(8);

	UPDATE djob.djob
		SET tsLastUpdate = @update_time
		FROM INSERTED
		WHERE djob.id = INSERTED.id
		;

	SELECT @vers = djob.[version] 
		FROM djob.djob, inserted
		WHERE djob.[id] = INSERTED.Id;

	INSERT INTO djob_history 
		( 
			[id]
		   ,[version]
           ,[tsLastUpdate]
		   ,[update_action]
		   ,[client_name]
           ,[name]
           ,[action]
           ,[state]
           ,[parameter]
           ,[intervall]
           ,[autoReset]
           ,[tsNextExecution]
           ,[tsLockAcquired]
           ,[owner]
           ,[tsLastExecution]
           ,[createdBy]
           ,[tsCreated]
           ,[tsModified]
           ,[avgRuntime]
           ,[avgRuntimeLast]
           ,[lastRuntime]
           ,[expectedRuntime]
           ,[job_version]
		)
		SELECT 			
			[id]
			,@vers
           ,@update_time
		   ,@event_type
		   , HOST_NAME()
           ,[name]
           ,[action]
           ,[state]
           ,[parameter]
           ,[intervall]
           ,[autoReset]
           ,[tsNextExecution]
           ,[tsLockAcquired]
           ,[owner]
           ,[tsLastExecution]
           ,[createdBy]
           ,[tsCreated]
           ,[tsModified]
           ,[avgRuntime]
           ,[avgRuntimeLast]
           ,[lastRuntime]
           ,[expectedRuntime]
           ,[job_version]
		 FROM INSERTED
		 ;
END;


	CREATE TRIGGER TRIG_DJOB_HISTORY_DELETE ON djob.djob
AFTER DELETE
AS
BEGIN
	SET NOCOUNT ON


	DECLARE @update_time DATETIME;
	SET @update_time = CURRENT_TIMESTAMP;

	INSERT INTO djob_history 
		( 
			[id]
		   ,[version]
           ,[tsLastUpdate]
		   ,[update_action]
		   ,[client_name]
           ,[name]
           ,[action]
           ,[state]
           ,[parameter]
           ,[intervall]
           ,[autoReset]
           ,[tsNextExecution]
           ,[tsLockAcquired]
           ,[owner]
           ,[tsLastExecution]
           ,[createdBy]
           ,[tsCreated]
           ,[tsModified]
           ,[avgRuntime]
           ,[avgRuntimeLast]
           ,[lastRuntime]
           ,[expectedRuntime]
           ,[job_version]
		)
		SELECT 			
			[id]
			,CONVERT( binary(8), '--------')
           ,@update_time
		   ,'D'
		   , HOST_NAME()
           ,[name]
           ,[action]
           ,[state]
           ,[parameter]
           ,[intervall]
           ,[autoReset]
           ,[tsNextExecution]
           ,[tsLockAcquired]
           ,[owner]
           ,[tsLastExecution]
           ,[createdBy]
           ,[tsCreated]
           ,[tsModified]
           ,[avgRuntime]
           ,[avgRuntimeLast]
           ,[lastRuntime]
           ,[expectedRuntime]
           ,[job_version]
		 FROM deleted
		 ;
END;
